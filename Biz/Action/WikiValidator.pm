# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::WikiValidator;
use strict;
use Bivio::Base 'Biz.Action';
b_use('IO.Trace');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_D) = b_use('Bivio.Die');
my($_FP) = b_use('Type.FilePath');
my($_HS) = b_use('Type.HTTPStatus');
my($_RF) = b_use('Model.RealmFile');
my($_FCT) = b_use('FacadeComponent.Text');
my($_WDN) = b_use('Type.WikiDataName');
my($_WN) = b_use('Type.WikiName');
my($_M) = b_use('Biz.Model');
my($_QUERY_KEY) = 'validate';
my($_T) = b_use('Agent.Task');
my($_V) = b_use('UI.View');
my($_WV) = b_use('Action.WikiView');
my($_A) = b_use('IO.Alert');
my($_TYPES) = [map(b_use("Type.$_"), qw(WikiName BlogFileName))];
my($_ER) = b_use('Action.EmptyReply');
my($_AA) = b_use('Action.Acknowledgement');

sub TYPE_LIST {
    return @$_TYPES;
}

sub call_embedded_task {
    my($proto, $uri, $wiki_state) = @_;
    my($req) = $wiki_state->{req};
    my($self) = ref($proto) ? $proto : $proto->unsafe_self_from_req($req);
    my($die);
    _trace($wiki_state->{path}, ': ', $uri) if $_TRACE;
    my($reply) = $_D->catch_quietly(
	sub {return b_use('AgentEmbed.Dispatcher')->call_task($req, $uri)},
	\$die,
    );
    return $self->validate_error($uri, _die_msg($die, $req), $wiki_state)
	unless $reply;
    $self->validate_error(
	$uri,
	$_FCT->facade_text_for_object($_HS->new($reply->get('status')), $req),
	$wiki_state,
    ) unless $reply->is_status_ok;
    return $reply;
}

sub return_with_validate {
    my($self, $task_return) = @_;
    ($task_return->{query} ||= {})->{$_QUERY_KEY} = 1;
    return $task_return;
}

sub send_mail {
    my($self, $email) = @_;
    b_die('unable to load error list')
	unless $self->unsafe_load_error_list;
    $self->put(to_email => $email);
    b_use('UI.View')->call_main('Wiki->validator_mail', $self->req);
    return;
}

sub unsafe_get_self {
    my($proto, $path, $req) = @_;
    return $req->unsafe_get($proto->as_classloader_map_name)
	|| $req->unsafe_from_query($_QUERY_KEY)
	&& $req->can_user_execute_task('FORUM_WIKI_EDIT')
	&& _new($proto, $path, $req)
        || $proto;
}

sub unsafe_load_error_list {
    my($self) = @_;
    return
	unless ref($self) and my $e = $self->get('errors');
    return
	unless @$e;
    return $_M->new($self->req, 'WikiErrorList')
	->load_from_array($self->get('errors'));
}

sub validate_error {
    my($self, $entity, $message, $wiki_state) = @_;
    b_warn($message, ': removed Perl junk: ', $1)
	if $message =~ s/(\w+(?:\:\:|\-\>)\w+.*)//;
    my($err) = {
	entity => $entity,
	message => $message,
    };
    if ($wiki_state) {
	$err->{path} = $wiki_state->{path};
	$err->{line_num} = $wiki_state->{line_num},
    }
    if (ref($self)) {
	$err->{path} ||= $self->unsafe_get('path');
	push(@{$self->get('errors')}, $err);
	return;
    }
    $wiki_state->{req}->warn(
	$err->{path} ? (
	    $err->{path},
	    $err->{line_num} ? (', line ', $err->{line_num}) : (),
	    ': ',
	) : (),
	$entity ? ($entity, ': ') : (),
	$message,
    );
    return;
}

sub validate_realm {
    my($proto, $req) = @_;
    $proto->delete_from_req($req);
    my($die);
    my($prev_task_id) = $req->get('task_id');
    $req->set_task('FORUM_WIKI_VIEW');
    my($self) = Bivio::Die->catch_quietly(
	sub {_validate_realm($proto, $req)},
	\$die,
    );
    $req->set_task($prev_task_id);
    ($self = _new($proto, undef, $req))
	->validate_error(undef, _die_msg($die, $req))
	unless $self;
    $self->put(errors => undef)
	unless @{$self->get('errors')};
    return $self
}

sub validate_uri {
    my($self, $uri, $wiki_state) = @_;
    return 1
	unless ref($self);
    return 1
	if $self->get('uri_cache')->{$uri}++;
#TODO: check external links (could even check mailto: if local)
    return 1
	if $uri =~ /^\w+:/i;
#TODO: Need simpler check, because not always in correct context
    return $self->call_embedded_task($uri, $wiki_state) ? 1 : 0;
}

sub _die_msg {
    my($die, $req) = @_;
    return $_FCT->facade_text_for_object($die->get('code'), $req);
}

sub _new {
    my($proto, $path, $req) = @_;
    return $proto->new({
	path => $path,
	uri_cache => {},
	errors => [],
    })->put_on_request($req);
}

sub _validate_path {
    my($self, $type, $seen) = @_;
    $_A->reset_warn_counter;
    my($path) = $self->get('path');
    my($p, $e) = $type =~ /Blog/ ? $type->from_literal($path)
	: $_FP->get_tail($path);
    unless ($type->is_valid($p)) {
	$self->validate_error(undef, 'Not a valid Wiki or Blog name')
	    unless $type->is_ignored_value($path);
	return;
    }
    $self->validate_error(
	undef,
	'Same name exists in Public and private areas',
    ) if $seen->{$p}++;
    my($req) = $self->req;
    my($die) = $_D->catch_quietly(sub {
	$req->delete(qw(query form_model path_info));
	if ($type =~ /Blog/) {
	    $_M->new($req, 'BlogList')->load_this({this => [$p]});
	    $_V->call_main('Blog->detail', $req);
	}
	else {
	    $_WV->execute_prepare_html($req, undef, undef, $p);
	    $_V->call_main('Wiki->view', $req);
	}
    });
    _trace($die) if $_TRACE;
    $req->get('reply')->delete_output;
    $self->validate_error(undef, _die_msg($die, $req))
	if $die;
    return;
}

sub _validate_realm {
    my($proto, $req) = @_;
    my($self) = _new($proto, undef, $req);
    $req->with_user(
	$_M->new($req, 'RealmUser')->unsafe_get_any_online_admin,
	sub {
	    $_M->new($req, 'BlogRecentList')->load_all;
	    foreach my $type (@$_TYPES) {
		my($seen) = {};
		my($paths) = $_M
		    ->new($req, $type =~ /Blog/ ? 'BlogList' : 'WikiList')
		    ->map_iterate(sub {shift->get('RealmFile.path')});
		foreach my $path (@$paths) {
		    $self->put(path => $path);
		    _validate_path($self, $type, $seen);
		}
	    }
	    return;
        },
    );
    return $self;
}

1;

