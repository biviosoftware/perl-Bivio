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
my($_M) = b_use('Biz.Model');
my($_QUERY_KEY) = 'validate';
my($_T) = b_use('Agent.Task');
my($_V) = b_use('UI.View');
my($_WV) = b_use('Action.WikiView');
my($_A) = b_use('IO.Alert');
my($_TYPES) = [map(b_use("Type.$_"), qw(WikiName BlogFileName))];
my($_ER) = b_use('Action.EmptyReply');
my($_AA) = b_use('Action.Acknowledgement');
my($_R) = b_use('Agent.Request');
my($_PKG) = __PACKAGE__;

sub TYPE_LIST {
    return @$_TYPES;
}

sub call_embedded_task {
    my($proto, $uri, $wiki_state) = @_;
    my($req) = $wiki_state->{req};
    my($self) = ref($proto) ? $proto : $proto->unsafe_self_from_req($req)
	|| $proto;
    my($die);
    _trace($wiki_state->{path}, ': ', $uri) if $_TRACE;
    my($reply) = $_D->catch_quietly(
	sub {return b_use('AgentEmbed.Dispatcher')->call_task($req, $uri)},
	\$die,
    );
    return $self->validate_error($uri, $die, $wiki_state)
	unless $reply;
    $self->validate_error($uri, $_HS->new($reply->get('status')), $wiki_state)
	unless $reply->is_status_ok;
    return $reply;
}

sub error_txt {
    my($self) = @_;
    b_die('unable to load error list')
	unless $self->unsafe_load_error_list;
    return b_use('UI.View')->render('Wiki->validator_txt', $self->req);
}

sub get_current_or_new {
    my($proto, $path, $realm_id, $req) = @_;
    return $req->unsafe_get($proto->as_classloader_map_name)
	|| $req->unsafe_from_query($_QUERY_KEY)
	&& $req->can_user_execute_task('FORUM_WIKI_EDIT')
	&& _new($proto, $path, $realm_id, $req)
        || $proto;
}

sub return_with_validate {
    my($self, $task_return) = @_;
    ($task_return->{query} ||= {})->{$_QUERY_KEY} = 1;
    return $task_return;
}

sub send_all_mail {
    my($self, $email, $all_txt) = @_;
    $self->put(
	to_email => $email,
	all_txt => $all_txt,
    );
    b_use('UI.View')->call_main('Wiki->validator_all_mail', $self->req);
    return;
}

sub send_mail {
    my($self, $email) = @_;
    b_die('unable to load error list')
	unless $self->unsafe_load_error_list;
    $self->put(to_email => $email);
    b_use('UI.View')->call_main('Wiki->validator_mail', $self->req);
    return;
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
    my($req) = $wiki_state && $wiki_state->{req} || $self->req;
    if ($_D->is_blesser_of($message)
        and my $prev_err = $message->get('attrs')->{$_PKG}
    ) {
	$message = $prev_err->{message};
	$entity = $prev_err->{entity};
    }
    $message = $_A->format_args(@$message)
	if ref($message) eq 'ARRAY';
    $message = $_FCT->facade_text_for_object(
	$_D->is_blesser_of($message) ? $message->get('code') : $message, $req,
    ) if ref($message);
    if ($message =~ s/(\w+(?:\:\:|\-\>)\w+.*)//) {
	b_warn($message, ': removed Perl junk: ', $1, '; ', $req);
	$_A->print_stack;
	$message ||= 'internal server error';
    }
    my($err) = {
	entity => $entity,
	message => $message,
    };
    if ($wiki_state) {
	my($cc) = $wiki_state->{calling_context};
	$err->{path} = $cc->get('file'),
	$err->{line_num} = $cc->get('line'),
    }
    $err->{path} ||= $self->unsafe_get('path');
    _trace($err) if $_TRACE;
    my($msg) = join(
	'',
	$err->{path} ? $err->{path} : (),
	$err->{line_num} ? (', line ', $err->{line_num}) : (),
	': ',
	$entity ? ($entity, ': ') : (),
	$message,
    );
    $_D->throw(DIE => {
	msg => $msg,
	$_PKG => $err,
    }) if $wiki_state && $wiki_state->{die_on_validate_error};
    return
	unless ref($self);
    my($re) = $self->get('ignore_regexp');
    return
	if $re && $msg =~ $re;
    push(@{$self->get('errors')}, $err);
    return;
}

sub validate_realm {
    my($proto, $req) = @_;
    $proto->delete_from_req($req);
    my($die);
#TODO: Probably want call embedded_task
    my($prev) = {map(($_ => $req->unsafe_get($_)), qw(task_id path_info query))};
    my($self) = Bivio::Die->catch_quietly(
	sub {_validate_realm($proto, $req)},
	\$die,
    );
    $req->set_task_and_uri($prev);
    ($self = _new($proto, undef, undef, $req))->validate_error(undef, $die)
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
    $uri = _uri_root($self, $wiki_state->{req}) . $uri
	unless $uri =~ m{^/};
#TODO: Need simpler check, because not always in correct context
    return $self->call_embedded_task($uri, $wiki_state) ? 1 : 0;
}

sub _ignore_regexp {
    my($realm_id, $req) = @_;
    return !$realm_id || $realm_id eq $req->get('auth_id')
	? $_M->new($req, 'WikiValidatorSettingList')
	    ->regexp_for_auth_realm
        : $req->with_realm($realm_id, sub {
	    return $_M->new($req, 'WikiValidatorSettingList')
	        ->regexp_for_auth_realm;
	});
}

sub _new {
    my($proto, $path, $realm_id, $req) = @_;
    return $proto->new({
	path => $path,
	uri_cache => {},
	errors => [],
	ignore_regexp => _ignore_regexp($realm_id, $req),
    })->put_on_request($req);
}

sub _uri_root {
    my($proto, $req) = @_;
    my($uri) = ($req->unsafe_get('initial_uri') || '') =~ m{^.*?(/.*/)};
    return $uri || '/';
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
	$req->put(
	    query => undef,
	    path_info => undef,
	)->delete('form_model');
	if ($type =~ /Blog/) {
	    $req->set_task_and_uri({task_id => 'FORUM_BLOG_DETAIL', path_info => $p});
	    $_M->new($req, 'BlogList')->load_this({this => [$p]});
	    $_V->call_main('Blog->detail', $req);
	}
	else {
	    $req->set_task_and_uri({task_id => 'FORUM_WIKI_VIEW', path_info => $p});
	    $_WV->execute_prepare_html($req, undef, undef, $p);
	    $_V->call_main('Wiki->view', $req);
	}
    });
    _trace($die) if $_TRACE;
    $req->get('reply')->delete_output;
    $self->validate_error(undef, $die)
	if $die;
    return;
}

sub _validate_realm {
    my($proto, $req) = @_;
    my($self) = _new($proto, undef, undef, $req);
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

