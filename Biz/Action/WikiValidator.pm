# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::WikiValidator;
use strict;
use Bivio::Base 'Action.JobBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
b_use('IO.Trace');
our($_TRACE);
my($_D) = b_use('Bivio.Die');
my($_FP) = b_use('Type.FilePath');
my($_HS) = b_use('Type.HTTPStatus');
my($_RF) = b_use('Model.RealmFile');
my($_T) = b_use('FacadeComponent.Text');
my($_WDN) = b_use('Type.WikiDataName');
my($_WN) = b_use('Type.WikiName');
my($_M) = b_use('Biz.Model');
my($_QUERY_KEY) = 'validate';

sub call_embedded_task {
    my($proto, $req, $uri) = @_;
    my($self) = ref($proto) ? $proto : $proto->unsafe_self_from_req($req);
    return b_use('AgentEmbed.Dispatcher')->call_task(
	$req,
	$uri,
	$self ? {$self->as_req_key_value_list} : (),
    );
}

sub do_errors {
    my($self) = @_;
    return;
}

sub internal_execute {
    my($self) = @_;
    # Runs for all realms
    # -- need to know which realm is in which facade
    return;
}

sub unsafe_get_self {
    my($proto, $req) = @_;
    return $req->unsafe_get($proto->as_classloader_map_name)
	|| $req->unsafe_get_from_query($_QUERY_KEY)
	&& $req->can_user_execute_task('FORUM_WIKI_EDIT')
	&& _new($proto, $req);
}

sub validate_all_in_realm {
    my($proto, $req) = @_;
    my($errors) = [];
    $req->with_user(
	$_M->new($req, 'RealmUser')->unsafe_get_any_online_admin,
	sub {
	    foreach my $type (qw(WikiName BlogFileName)) {
		foreach my $public (0, 1) {
		    push(@$errors,
		        @{$_M->new($req, 'RealmFileList')->map_iterate(
			    sub {_execute($proto, shift)},
			    {path_info => b_use("Type.$type")
				 ->to_absolute(undef, $public)},
			)},
		    );
		}
	    }
	    return;
        },
    );
    return $errors;
}

sub validate_uri {
    my($self, $uri, $req) = @_;
#TODO: check external links (could even check mailto: if local)
    return
	if $uri =~ /^\w+:/i;
    my($die);
    my($reply) = Bivio::Die->catch_quietly(
	sub {$self->call_embedded_task($req, $uri)},
	\$die,
    );
    return
	if $reply && $reply->is_status_ok;
    return $_T->facade_text_for_object(
	$die ? $die->get('code') : $_HS->new($reply->get('status')),
	$req,
    );
}

sub validation_error {
    my($self, $args) = @_;
    push(@{$self->get('errors')}, $args);
    return;
}

sub _execute {
    my($proto, $rfl) = @_;
    my($req) = $rfl->req;
    my($self) = _new($proto, $req);
    if (my $die = $_D->catch_quietly(sub {
        # ASSUME: invalid names are not important
	return
	    unless $_WN->is_valid(
		$_FP->get_tail($rfl->get('RealmFile.path')));
#TODO: Need to execute the task (not embedded) to get the menus
	# Avoid circular import
        b_use('XHTMLWidget.WikiText')->render_html({
	    value => ${$rfl->get_content},
	    name => $rfl->get('RealmFile.path'),
	    req => $req,
	    map(($_ => $rfl->get("RealmFile.$_")), qw(is_public realm_id)),
	});
	return;
    })) {
	_trace($rfl->get('RealmFile.path'), ': ', $die) if $_TRACE;
	$self->validation_error({
	    entity => $rfl->get('RealmFile.path'),
	    message => $_T->facade_text_for_object($die->get('code')),
	});
    }
    return @{$self->get('errors')};
}

sub _new {
    my($proto, $req) = @_;
    return $proto->new({errors => []})->put_on_request($req);
}

1;
