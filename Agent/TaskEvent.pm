# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Agent::TaskEvent;
use strict;
use Bivio::Base 'Collection.Attributes';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_R) = b_use('IO.Ref');
my($_S) = b_use('Type.String');
my($_TI) = b_use('Agent.TaskId');
my($_DC) = b_use('Bivio.DieCode');
my($_PARAMS) = [
    @{Bivio::Agent::Request->FORMAT_URI_PARAMETERS},
    qw(no_form method),
];
my($_DEFAULTS) = {
    map(($_ => undef), @$_PARAMS),
    method => 'client_redirect',
};
my($_EXPECTED) = {
    put_durable_server_redirect_state => [@$_PARAMS, qw(form form_model)],
    server_redirect => [qw(
        task_id realm query form path_info no_context require_context no_form
    )],
    client_redirect => [qw(
        task_id realm query path_info no_context require_context no_form uri
    )],
};
my($_IMPLICIT_OVERRIDE) = {
    carry_query => 1,
    carry_path_info => 1,
};

sub internal_as_string {
    my($self) = @_;
    my($a) = $self->get_shallow_copy;
    return map(
	$_S->compare($a->{$_}, $_DEFAULTS->{$_}) == 0 ? ()
	    : "$_=" . ($_ eq 'task_id' ? $a->{$_}->get_name
	    : $_R->to_short_string($a->{$_})),
	@$_PARAMS,
    );
}

sub call_method {
    my($self, $object, $method, $override) = @_;
    my($c) = $self->get_shallow_copy;
    $method ||= $c->{method} || b_die($self, ': no method');
    my($e) = $_EXPECTED->{$method} || b_die($method, ': unconfigured method');
    return $object->$method({
	map(exists($c->{$_}) ? ($_ => $c->{$_}) : (), @$e),
	$override ? %$override : (),
    });
}

sub new {
    my($proto, $params, $req) = @_;
    my($self) = shift->SUPER::new({%$_DEFAULTS, %$params});
    $params = $self->internal_get;
    $params->{task_id} &&= $_TI->from_any($params->{task_id});
    foreach my $k (qw(path_info query)) {
	$params->{$k} = $req->unsafe_get($k)
	    if $params->{"carry_$k"};
    }
    return $self->internal_put($params);
}


sub parse_die {
    my($proto, $die, $task, $req) = @_;
    my($die_code) = $die->get('code');
    my($params) = $task->unsafe_params_for_die_code($die_code);
    unless (defined($params)) {
	# Default mapped?
	my($n) = 'DEFAULT_ERROR_REDIRECT_' . $die_code->get_name;
	my($t) = $_TI->unsafe_from_name($n)
	    || $_TI->unsafe_from_name($n = 'DEFAULT_ERROR_REDIRECT');
	unless (defined($t)) {
	    _trace('not a mapped task: ', $die_code) if $_TRACE;
	    return;
	}
	$params = _assert_params($n, $t);
    }
    unless (b_use('UI.Task')->is_defined_for_facade($params->{task_id}, $req)) {
	_trace('error redirect not defined in facade: ', $params)
	    if $_TRACE;
	return;
    }
    if ($req->need_to_secure_task($task->get_by_id($params->{task_id}))) {
	$req->put_client_redirect_state($params);
	$die->set_code($_DC->CLIENT_REDIRECT_TASK);
	return;
    }
    $die->set_code(
	$_DC->SERVER_REDIRECT_TASK,
	task_id => $params->{task_id},
    );
#TODO: Figure out how to save the current form in context if there is one.
#      Cannot simply call $req->get_form here, because it has to be
#      parsed into internal_values by FormModel.
    # Leave uri untouched.
    $proto->new({%$_IMPLICIT_OVERRIDE, %$params}, $req)
	->call_method($req, put_durable_server_redirect_state => {
	    form => undef,
	    form_model => undef,
	});
    return;
}

sub parse_item {
    my($proto, $cause, $params) = @_;
    return _assert_params($cause, $params);
}

sub parse_item_result {
    my($proto, $params, $task, $req, $item) = @_;
    my($override) = {};
    if (ref($params) eq 'HASH') {
	if ($params->{method}) {
	    return 0
		if $params->{method} eq 'next_item_execute';
	    return 1
		if $params->{method} eq 'last_item_execute';
	}
	$params->{task_id} ||= 'next'
	    unless $params->{uri};
    }
    else {
	return 1
	    if $params eq '1';
	b_die('server_redirect.*: invalid form, use a hash')
	    if $params =~ /^(server_redirect)\./;
	$params = {task_id => $params};
	$override = $_IMPLICIT_OVERRIDE;
    }
    unless ($params->{uri} || $_TI->is_blessed($params->{task_id})) {
	if (($params->{task_id} || '') =~ $task->TASK_ATTR_RE) {
	    $params = {
		%{$task->dep_get_attr(delete($params->{task_id}))},
		%$params,
	    };
	}
	else {
	    b_die(
		$params,
		': invalid task_id returned by ',
		_item_as_string($task, $item),
	    ) unless $params->{task_id}
	    = $_TI->unsafe_from_name($params->{task_id});
	}
    }
    return $proto->new(
	_assert_params(
	    _item_as_string($task, $item),
	    {%$override, %$params},
	),
	$req,
    );
}

sub _assert_params {
    my($cause, $params) = @_;
    $params = {
	task_id => $params,
	no_context => 0,
	method => 'client_redirect',
    } unless ref($params) eq 'HASH';
    if ($params->{task_id}) {
	unless (exists($params->{uri})) {
	    $params->{task_id} = $_TI->from_any($params->{task_id});
	    return $params;
	}
    }
    elsif ($params->{uri}) {
	my($u) = $params->{uri};
	b_die($u, ': uri must begin with a / or a scheme: ', $cause)
	    unless $u =~ m{^(?:/|\w+:)}s;
	b_die($cause, ': uri *query and *path_info are mutually exclusive: ', $params)
	    if $u =~ /\?/
	    && grep(/path_info|query/ && $params->{$_}, keys(%$params));
	$params->{carry_query} = 0;
	$params->{carry_path_info} = 0;
	return $params;
    }
    b_die($cause, ': params must have uri OR task_id but not both: ', $params);
    # DOES NOT RETURN
}


sub _item_as_string {
    my($task, $item) = @_;
    my($instance, $method, $args) = @$item;
    return $task->get('id')->get_name
	. '['
	. (defined($instance)
	  ? (ref($instance) || $instance) . '->' . $method
	  : 'code'
        ) . ']';
}


1;
