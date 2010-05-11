# Copyright (c) 2002-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Request;
use strict;
use Bivio::Base 'AgentJob.Request';
use Socket ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_B) = b_use('Test.Bean');
my($_RI) = b_use('Agent.RequestId');
b_use('Bivio.Test')->register_handler(__PACKAGE__);
my($_CL) = b_use('IO.ClassLoader');

sub get_instance {
    return shift->get_current_or_new(@_);
}

sub new_unit {
    my($proto, $class_name, $method, @args) = @_;
    b_die('request already exists: ', $proto->get_current)
        if $proto->get_current;
    $method ||= 'get_instance';
    return $proto->$method(@args)->put(class_name => $class_name);
}

sub capture_mail {
    my($self) = @_;
    $self->unsafe_get_captured_mail;
    return $self;
}

sub client_redirect {
    return _redirect_check(shift)->server_redirect(@_);
}

sub commit {
    return b_use('Agent.Task')->commit(shift(@_));
}

sub delete_class_from_self {
    my($self, $class) = @_;
    $self->delete(
	$class,
	$self->use($class),
    );
    return;
}

sub execute_task {
    my($self) = shift->initialize_fully(@_);
#TODO: hacked - remove the list model or PropertyModel::_parse_query() fails
    $self->req->delete('list_model');
    $self->capture_mail;
    $self->get('task')->execute($self);
    my($o) = $self->get('reply')->get_output;
    return [$o ? $$o : undef, @{$self->unsafe_get_captured_mail}];
}

sub format_http_toggling_secure {
    my($self) = @_;
    return '';
}

sub get_current_or_new {
    my($proto) = @_;
    my($self) = $proto->get_current;
    return $self
	if $self;
    $self = $proto->new({
	auth_id => undef,
	auth_user_id => undef,
	task_id => b_use('Agent.TaskId')->SHELL_UTIL,
	timezone => b_use('Type.DateTime')->timezone,
	is_secure => 0,
	disable_assert_cookie => 1,
    })->put(
	reply => b_use('Test.Reply')->new,
    );
    $self->set_realm(undef);
    $self->set_user(undef);
    return $self;
}

sub get_form {
    return shift->unsafe_get('form');
}

sub handle_prepare_case {
    my($proto) = @_;
    return
	unless my $self = $proto->get_current;
    $_RI->clear_current($self);
    return;
}

sub initialize_fully {
    my($self) = shift(@_);
    $self = $self->get_instance unless ref($self);
    my($task_id, $req_attrs, $facade_name) = @_;
    ($req_attrs ||= {})->{task_id} = b_use('Agent.TaskId')->from_any(
	$task_id || $self->unsafe_get('task_id') || 'SHELL_UTIL');
    b_use('Agent.Dispatcher')->initialize;
    $self->put(%$req_attrs);
    if ($facade_name) {
	$self->setup_facade($facade_name);
    }
    else {
	$self->setup_all_facades;
    }
    b_die(
	'facade not fully initialized; this method must be called before'
	. ' any setup_facade or Bivio::ShellUtil->initialize_ui'
    ) unless b_use('UI.Facade')->is_fully_initialized;
    $self->put_durable(uri => $self->format_uri)
        if b_use('FacadeComponent.Task')->has_uri($self->get('task_id'), $self);
    return $self;
}

sub internal_redirect_user_realm {
    shift->throw_die(FORBIDDEN => {
	entity => shift,
	message => 'no realm to guess',
    });
    # DOES NOT RETURN
}

sub is_test {
    my($self) = @_;
    return $self->get_or_default('is_test', shift->SUPER::is_test(@_));
}

sub put_form {
    my($self, $form, $fields) = @_;
    return $self->put(form => {
	$form->VERSION_FIELD => $form->get_info('version'),
	map({
	    my($f) = $_;
	    # There are sometimes junk fields in fields of form, e.g.
	    # ListFormModel fields.
	    defined($form->get_field_name_for_html($f))
	        ? ($form->get_field_name_for_html($f) =>
		    $form->get_field_type($f)->to_literal($fields->{$f}))
	        : ();
	} keys(%$fields)),
    });
}

sub put_on_query {
    my($self) = shift;
    my($query) = $self->get_if_defined_else_put(query => {});
    $self->map_by_two(sub {
	my($k, $v) = @_;
	$query->{_maybe_to_char($k)} = $v;
    }, \@_);
    return $self;
}

sub run_unit {
    return shift->use('TestUnit.Unit')->run_unit(@_);
}

sub server_redirect {
    my($self) = _redirect_check(shift);
    my(undef, $named) = $self->internal_client_redirect_args(@_);
    b_die($named, ': uris not supported yet')
        if defined($named->{uri});
    $self->internal_server_redirect($named);
    return;
}

sub set_realm_and_user {
    my($self) = shift;
    $self = $self->get_instance
	unless ref($self);
    b_use('Bivio.ShellUtil')->set_realm_and_user(@_);
    return $self;
}

sub setup_all_facades {
    my($self) = shift->setup_http;
    b_use('Agent.Dispatcher')->initialize(0);
    return $self->setup_facade;
}

sub setup_facade {
    my($proto, $facade) = @_;
    my($self) = $proto->setup_http;
    b_use('Bivio.ShellUtil')->initialize_ui;
    b_use('UI.Facade')->setup_request($facade, $self)
        if $facade;
    return $self;
}

sub setup_http {
    my($self, $cookie_class) = @_;
    $self = $self->get_instance
	unless ref($self);
    return $self
	if $self->unsafe_get('r');
    # What's required by bOP infrastructure.
    b_use('Type.UserAgent')->BROWSER_HTML4->execute($self, 1);
    my($ip) = '127.0.0.1';
    my($addr) = Socket::pack_sockaddr_in(80, Socket::inet_aton($ip));
    my($method) = 'GET';
    my($header) = {};
    # header_in and header_out have different names
    my($header_op) = sub {
	my($args) = @_;
	return !@$args ? %$header
	    : @$args > 1 ? ($header->{$args->[0]} = $args->[1])
	    : $header->{$args->[0]};
    };
    my($r) = $_B->new({
	'connection()' => [$_B->new({
	    'remote_ip()' => [$ip],
	    'local_addr()' => [$addr],
	    'server()' => [$_B->new({})],
	    'user()' => [],
	})],
	'method()' => sub {
	    my($args) = @_;
	    return @$args ? ($method = $args->[0]) : $method;
	},
	'uri()' => ['/'],
	'header_in()' => $header_op,
	'header_out()' => $header_op,
	'hostname()' => ['localhost.localdomain'],
	'get_server_port()' => [80],
    });
    $self->put_durable(r => $r);
    b_use('IO.Config')->introduce_values({
	'Bivio::IO::ClassLoader' => {
	    delegates => {
		'Bivio::Agent::HTTP::Cookie' =>
		    $cookie_class || 'Bivio::Delegate::NoCookie',
	    },
	},
    }) unless $_CL->was_required('Bivio::Agent::HTTP::Cookie');
    # Cookie overwrites, so we have to reset below
    my($user) = $self->get('auth_user');
    $self->put_durable(
	uri => '/',
	path_info => $self->unsafe_get('path_info'),
	query => $self->unsafe_get('query'),
	cookie => b_use('AgentHTTP.Cookie')->new($self, $r),
	client_addr => $ip,
	user_state => b_use('Type.UserState')->JUST_VISITOR,
    );
    # Sets user after cookie clears it
    if ($user) {
	if ($user->is_default) {
	    $self->set_user($user);
	}
	else {
	    b_use('Model.UserLoginForm')->execute($self, {
		realm_owner => $user,
	    });
	}
	$self->put_durable(user_state => $self->get('user_state')->LOGGED_IN); 
    }
    b_use('Action.JobBase')->set_sentinel($self);
    return $self;
}

sub set_user_state_and_cookie {
    my($self, $user_state, $user) = @_;
    $user_state = b_use('Type.UserState')->from_any($user_state);
    $self->put_unless_exists(cookie => b_use('Collection.Attributes')->new);
    my($ulf) = b_use('Model.UserLoginForm')->new($self);
    $ulf->process({login => $user});
    $ulf->process({login => undef})
	if $user_state->eq_logged_out;
    return $self;
}

sub unsafe_get_captured_mail {
    my($self) = @_;
    my($res) = [];
    $self->put(txn_resources => [
	map({
	    !$_->isa('Bivio::Mail::Outgoing') ? $_
		: (sub {push(@$res, shift->as_string); return})->($_);
	} @{$self->get('txn_resources')}),
    ]);
    return $res;
}

sub _maybe_to_char {
    my($key) = @_;
    my($die);
    return b_use('Bivio.Die')->catch(sub {
	return b_use('SQL.ListQuery')->to_char($key);
    }, \$die) || $key;
}

sub _redirect_check {
    my($self) = @_;
    my($n) = ref($self) . '._redirect_check';
    my($r) = $self->get_if_exists_else_put($n => 1);
    if ((caller(1))[0]->isa('Bivio::Agent::Request')) {
	# high number b/c client_redirect calls server_redirect
	$self->throw_die(DIE => {
	    message => 'too many directs',
	}) if ++$r > 10;
    }
    else {
	$r = 1;
    }
    return $self->put($n => $r);
}

1;
