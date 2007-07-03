# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Task;
use strict;
use Bivio::Agent::TaskId;
use Bivio::Auth::PermissionSet;
use Bivio::Auth::RealmType;
use Bivio::Base 'Bivio::Collection::Attributes';
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;
use Bivio::Type::Boolean;

# C<Bivio::Agent::Task> defines a tuple which is configured by
# L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.
#
# The following fields are returned by L<get|"get">:
#
#
# cancel : Bivio::Agent::TaskId [next]
#
# The task_id to go to in other cases.  In the case forms, is the "Cancel" task
# of a form.
#
# die_actions : hash_ref (see below for configuration)
#
# The map of die codes (any enums, actually) to tasks executed when
# the die code is encountered for this task.  I<Only maps if the
# request is from HTTP.>
# Specified in L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>
# and passed to L<new|"new"> as:
#
#     DIE_CODE=TASK_ID
#
# The name of a L<Bivio::DieCode|Bivio::DieCode> or a fully
# specified enum, e.g. C<Bivio::TypeError::EXISTS>.  The action
# will be executed if this enum is thrown.
#
# form_model : Bivio::Biz::FormModel (computed)
#
# The form model in I<items> or C<undef>.
#
# id : Bivio::Agent::TaskId (required)
#
# L<Bivio::Agent::TaskId|Bivio::Agent::TaskId> for this task.
#
# items : array_ref (required)
#
# A list of actions.  An action is the tuple (singleton instance,
# method name).  When the task is executed, the methods are
# called on the singletons.  If the singleton is undefined,
# it means the method is a subroutine to be called without
# an instance.
#
# next : Bivio::Agent::TaskId []
#
# The next task_id to go to in certain cases.  Required only if
# there is a FormModel in I<items>.
#
# permission_set : Bivio::Auth::Permission (required)
#
# L<Bivio::Auth::Permission|Bivio::Auth::PermissionSet> for this task.
# Specified in TaskId and passed to L<new|"new"> as:
#
#     PERMISSION_1&PERMISSION_2
#
# where PERMISSION_n are names of
# L<Bivio::Auth::Permission|Bivio::Auth::Permission>.  All permissions
# must be set for the task to be executable by the current
# L<Bivio::Auth::Role|Bivio::Auth::Role>.
#
# realm_type : Bivio::Auth::RealmType (required)
#
# L<Bivio::Auth::RealmType|Bivio::Auth::RealmType> for this task.
# Specified in L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>
# and passed to L<new|"new"> as:
#
#      REALM_TYPE
#
# where REALM_TYPE is one of the names of
# L<Bivio::Auth::RealmType|Bivio::Auth::RealmType>.  This defines
# the security realm, and the names space to find the
# L<Bivio::Biz::Model::RealmOwner|Bivio::Biz::Model::RealmOwner>.
#
# require_context : boolean [form_model's require_context]
#
# The I<form_model> has C<require_context> defined, unless
# overriden by the configuration.  You can't turn on I<require_context>
# if the I<form_model> doesn't require it already.
#
# want_query : boolean [1]
#
# L<Bivio::Agent::Request|Bivio::Agent::Request> will not add the query
# (even if supplied) if this is false.
#
# want_workflow : boolean [0]
#
# If true, the current task is part of a multi-task workflow.  Go to the next
# task on L<Bivio::Biz::FormModel|Bivio::Biz::FormModel> execute_ok, even if
# there is L<Bivio::Biz::FormContext|Bivio::Biz::FormContext>.  The FormContext
# is copied to the new task verbatim.  It's like a "goto" the next task (think:
# tail recursion) and only return when you are at the end of the workflow
# (want_workflow is false on that task).
#
# want_[a-z0-9_]+ : boolean []
#
# Custom boolean attribute.
#
# require_secure : boolean [0]
#
# Task must be in secure mode to function.
#
# require_[a-z0-9_]+ : boolean []
#
# Custom boolean attribute.
#
# [a-z0-9_]+_task : Bivio::Agent::TaskId []
#
# Custom task value for redirects.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_T) = 'Bivio::Agent::TaskId';
my(%_ID_TO_TASK) = ();
my($_INITIALIZED);
my(%_REDIRECT_DIE_CODES) = (
    Bivio::DieCode->CLIENT_REDIRECT_TASK => 1,
    Bivio::DieCode->SERVER_REDIRECT_TASK => 1,
);
my($_REQUEST_LOADED);
my(@_HANDLERS);

sub commit {
    my(undef, $req) = @_;
    # Commits transactions to storage if necessary, but first calls
    # handle_commit for txn_resources.
    # These modules are intelligent and won't do anything if there
    # were no modifications.
    #
    _call_txn_resources($req, 'handle_commit');
    Bivio::SQL::Connection->commit;
#TODO: Garbage collect state that doesn't agree with SQL DB
    # Note: rollback is in handle_die
    return;
}

sub execute {
    my($self, $req) = @_;
    # Executes the task for the specified request.  Checks that the request is
    # authorized.  Calls C<commit> and C<send_queued_messages> if there is an action.
    # Calls C<reply-E<gt>send>.
    #
    # If I<execute> returns true, stops item execution.  If the return result
    # is a L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>, control will be
    # redirected to with L<Bivio::Agent::Request::client_redirect|Bivio::Agent::Request/"client_redirect">.
    #
    # B<Must be called within L<Bivio::Die::catch|Bivio::Die/"catch">.> Depends on
    # the fact that L<handle_die|"handle_die"> is called to execute rollback.
    $req->client_redirect_if_not_secure
	if $self->get('require_secure')
	&& $req->can('client_redirect_if_not_secure');
    _invoke_handlers(handle_pre_auth_task => $req);
    unless ($req->get('auth_realm')->can_user_execute_task($self, $req)) {
	Bivio::Die->throw_quietly('FORBIDDEN', {
	    map(($_ => $req->get($_)),
		qw(auth_realm auth_user auth_roles auth_role)),
	    operation => $self->get('id'),
	});
    }
    _invoke_handlers(handle_pre_execute_task => $req);
    my($next, $method) = $self->execute_items($req);
    $req->$method($next)
	if $next;
    _invoke_handlers(handle_post_execute_task => $req);
    $self->commit($req);
    $req->get('reply')->send($req);
    return;
}

sub execute_items {
    my($self, $req) = @_;
    # Executes the items on the task.  Does not call the preexecute handler and
    # does not authorize (does not call can_user_execute_task).
    foreach my $i (@{$self->get('items')}) {
	my($instance, $method, $args) = @$i;
	# Don't continue if returns true.
	my($res) = $instance->$method(@$args, $req);
	next unless $res;
	my($next) = $res;
	my($redirect) = ref($next) eq 'HASH' && delete($next->{method})
	    || 'client_redirect';
	unless (ref($res)) {
	    # Boolean true means "I'm done"
	    last if $res eq '1';
	    $redirect = 'server_redirect'
		if $res =~ s/^(server_redirect)\.//;
 	    $next = $self->unsafe_get($res)
		|| $_T->is_valid_name($res) && $_T->from_name($res)
		|| $res;
	}
	elsif (ref($res) eq 'HASH' && ($res->{task_id} || '') =~ /(?:^next|^cancel|_task)$/) {
	    $res->{task_id} = $self->unsafe_get($res->{task_id})
		|| $res->{task_id};
	}
	_trace($redirect, '.', $next, ' ', $req->unsafe_get('query'))
	    if $_TRACE;
	Bivio::Die->die(
	    $self->get('id'), ' item ',
	    defined($instance) ? (ref($instance) || $instance) . '->' . $method
		: 'code',
	    ': must return boolean, hash_ref, Bivio::Agent::TaskId, or attribute not ',
	    $res,
	) unless ref($next) eq 'HASH' || UNIVERSAL::isa($next, $_T);
	return ($next, $redirect);
    }
    return;
}

sub execute_task_item {
    my($proto, $arg, $req) = @_;
    # General: Executes a task item.  Classes which implement this method will get
    # called with I<arg> instead of the more traditional C<execute> method name.
    # See Bivio::UI::View for an example.
    #
    # Specific: This module has a handle_task_item which is used to execute
    # inline subs that are task items.
    return $arg->($req);
}

sub get_by_id {
    my(undef, $id) = @_;
    # Returns the task associated with the id.
    $id = $_T->from_name($id)
        unless ref($id);
    Bivio::Die->die($id, ": no task associated with id")
	unless $_ID_TO_TASK{$id};
    return $_ID_TO_TASK{$id};
}

sub handle_die {
    my($proto, $die) = @_;
    # Something happened while executing a request, so we have to rollback
    #  unless is a C<CLIENT_REDIRECT_TASK> or C<SERVER_REDIRECT_TASK>.
    #
    # If I<proto> is a reference which can map the I<die> code in
    # one of its I<die_actions> (cannot be redirect code) if the
    # request is from HTTP.
    #
    # The die code is converted to C<SERVER_REDIRECT_TASK>
    # with the mapped die_action set as its I<task_id> attribute.
    #
    # If no specific I<die_action> is found, the C<DEFAULT_ERROR_REDIRECT_>
    # task id is sought.
    my($die_code) = $die->get('code');
    unless ($_REQUEST_LOADED) {
	Bivio::IO::ClassLoader->simple_require('Bivio::Agent::Request');
	$_REQUEST_LOADED = 1;
    }
    if ($_REDIRECT_DIE_CODES{$die_code}) {
	# commit redirects: current task is completed
	_trace('commit: ', $die_code) if $_TRACE;
	$proto->commit(Bivio::Agent::Request->get_current);
	return;
    }

    my($req) = Bivio::Agent::Request->get_current;
    $proto->rollback($req);

    # Don't clutter logs with forbidden -> login redirects
    $req->warn('task_error=', $die)
	if $req
	&& (!$die->get('code')->equals_by_name('FORBIDDEN')
		|| $req->get('auth_user'));

    # Is this an HTTP request? (We don't redirect on non-http requests)
    unless (UNIVERSAL::isa($req, 'Bivio::Agent::HTTP::Request')) {
	_trace('not an http request: ', $req) if $_TRACE;
	return;
    }

    # Some type of unhandled error.  Rollback and check die_actions
    unless (ref($proto)) {
	_trace('called statically (probably should not happen)') if $_TRACE;
	return;
    }

    # Mapped?
    my($new_task_id) = $proto->get('die_actions')->{$die_code};
    unless (defined($new_task_id)) {
	# Default mapped?
	$new_task_id = $_T->unsafe_from_any(
	    'DEFAULT_ERROR_REDIRECT_' . $die_code->get_name);
	unless (defined($new_task_id)) {
	    _trace('not a mapped task: ', $die_code) if $_TRACE;
	    return;
	}
    }
    # Allowed?
    unless (Bivio::UI::Task->is_defined_for_facade($new_task_id, $req)) {
	_trace('error redirect not defined in facade: ', $new_task_id)
	    if $_TRACE;
	return;
    }

    # error_redirect listed on a task
    $die->set_code(
	Bivio::DieCode->SERVER_REDIRECT_TASK,
	task_id => $new_task_id,
    );
#TODO: Figure out how to save the current form in context if there is one.
#      Cannot simply call $req->get_form here, because it has to be
#      parsed into internal_values by FormModel.
    # Leave uri untouched.
    $req->put_durable_server_redirect_state({
	task_id => $new_task_id,
	form => undef,
	form_model => undef,
    });
    return;
}

sub initialize {
    my($proto, $partially) = @_;
    # Initializes task list from the configuration in
    # L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.
    #
    # I<partially> allows this module to initialize only part of the
    # task state.  This is only used by L<Bivio::ShellUtil|Bivio::ShellUtil>
    # to speed up command line initialization.  B<Never use in a server.>
    return if $_INITIALIZED;
    $_INITIALIZED = 1;

    foreach my $cfg (@{$_T->get_cfg_list}) {
	my($id_name, undef, $realm_type, $perm_spec, @items) = @$cfg;
	my($perm_set) = Bivio::Auth::PermissionSet->get_min;
	foreach my $p (split(/\&/, $perm_spec)) {
	    Bivio::Auth::PermissionSet->set(\$perm_set,
		    Bivio::Auth::Permission->$p());
	}
	$proto->new($_T->$id_name(),
		Bivio::Auth::RealmType->$realm_type(),
		$perm_set, $partially ? () : @items);
    };
    return;
}

sub new {
    my($proto, $id, $realm_type, $perm, @items) = @_;
    # Creates a new task for I<id> with I<perm> and I<realm_type>.
    # A task must not already be
    # bound to the I<id>.   The rest of the arguments are
    # items to be executed (in order) or mapped.  An executable item must be a
    # class with an C<execute> method, of the form C<class-E<gt>method>,
    # or a C<CODE> reference, i.e. a C<sub> which takes a C<$req> as
    # a parameter.  Here are some examples:
    #
    #     Model.UserLoginForm
    #     View.user-login
    #
    # See L<Bivio::Delegate::SimpleTaskId|Bivio::Delegate::SimpleTaskId>
    # and L<Bivio::PetShop::Agent::TaskId|Bivio::PetShop::Agent::TaskId>
    # for complete examples.
    #
    # There may only be one FormModel in the items of a task.
    #
    # A mapping item is of the form I<name>=I<action>, where I<name>
    # and I<action> are attributes as defined above.

    # Validate $id
    die("id invalid") unless $id->isa($_T);
    die("realm_type invalid")
	    unless $realm_type->isa('Bivio::Auth::RealmType');
    die($id->as_string, ': id already defined') if $_ID_TO_TASK{$id};

    my($self) = $proto->SUPER::new({
	id => $id,
	realm_type => $realm_type,
	permission_set => $perm,
	die_actions => {},
	form_model => undef,
    });
    my($attrs) = $self->internal_get;
    # Make the task visible to the items being initialized
    $_ID_TO_TASK{$id} = $self;
    my(@executables);
    foreach my $i (@items) {
	if ($i =~ /=/) {
	    # Map item
	    _parse_map_item($attrs, split(/=/, $i, 2));
	    next;
	}
	push(@executables, $i);
    }
    my($new_items) = _init_executables($proto, $attrs, \@executables);
    # Set form
    _init_form_attrs($attrs);

    foreach my $x (
	[want_query => 1],
	[require_secure => 0],
	[want_workflow => 0],
    ) {
	$attrs->{$x->[0]} = $x->[1]
	    unless defined($attrs->{$x->[0]});
    }
    $attrs->{items} = $new_items;
    $self->set_read_only;
    return $self;
}

sub register {
    my($proto, $handler) = @_;
    # Registers a pre execution handler if not already registered. The I<handler>
    # must support L<handle_pre_execute_task|"handle_pre_execute_task"> or
    # L<handle_pre_auth_task|"handle_pre_auth_task">.
    push(@_HANDLERS, $handler)
	unless grep($_ eq $handler, @_HANDLERS);
    return;
}

sub rollback {
    my(undef, $req) = @_;
    # Rollback the current transaction.  Call C<handle_rollback> with
    # L<txn_resources|"txn_resources">.
    #
    # Called from L<Bivio::Biz::FormModel|Bivio::Biz::FormModel>.
    # NOTE: Bivio::Biz::Model::Lock::release behaves a particular way
    # and this code must stay in synch with it.
    _call_txn_resources($req, 'handle_rollback');
    Bivio::SQL::Connection->rollback;
    return;
}

sub unsafe_get_redirect {
    my($self, $attr, $req) = @_;
    # Returns the task associated with I<attr> on I<self>, if it exists and is
    # defined in the facade.
    return undef
	unless my $v = $self->unsafe_get($attr);
     return Bivio::UI::Task->is_defined_for_facade($v, $req) ? $v : undef;
}

sub _call_txn_resources {
    my($req, $method) = @_;
    # Call the transaction resource handlers.
    return unless $req;
    my($resources) = $req->unsafe_get('txn_resources');
    $req->put(txn_resources => []);
    if (ref($resources) eq 'ARRAY') {
	while (my $r = pop(@$resources)) {
	    _trace($r, '->', $method) if $_TRACE;
	    $r->$method($req);
	}
    }
    return;
}

sub _init_executables {
    my($proto, $attrs, $executables) = @_;
    # Returns the parsed and initialized executables.
    my(@new_items);
    foreach my $i (@$executables) {
	if (ref($i) eq 'CODE') {
	    push(@new_items, [$proto, execute_task_item => [$i]]);
	    next;
	}
	if ($i =~ /^View\.([a-z].*)/) {
	    my($view) = $1;
	    push(@new_items,
	        [$proto->use('View.LocalFile'), 'execute_task_item', [$view]]);
	    next;
	}
	my($class, $method) = split(/->/, $i, 2);
	my($c) = $proto->use($class);
	$c = $c->get_instance
	    if $c->can('get_instance');
	if ($c->can('execute_task_item') && $method) {
	    push(@new_items, [$c, execute_task_item => [$method]]);
	}
	else {
	    $method ||= 'execute';
	    Bivio::Die->die($i, ": can't be executed (missing $method method)")
	        unless $c->can($method) || $c->can('AUTOLOAD');
	    push(@new_items, [$c, $method, []]);
	}
	if ($c->isa('Bivio::Biz::FormModel')) {
	    Bivio::Die->die($attrs->{id}, ': too many form models')
	        if $attrs->{form_model};
	    $attrs->{form_model} = ref($c) || $c;
	}
    }
    return \@new_items;
}

sub _init_form_attrs {
    my($attrs) = @_;
    # Initializes the form_model attributes.
    unless ($attrs->{form_model}) {
	$attrs->{require_context} = 0;
	return;
    }

    Bivio::Die->die($attrs->{id}, ": FormModels require \"next=\" item")
	unless $attrs->{next};
    # default cancel to next unless present
    $attrs->{cancel} = $attrs->{next} unless $attrs->{cancel};

    my($form_require) = $attrs->{form_model}->get_instance
	->get_info('require_context');
    if (defined($attrs->{require_context})) {
	Bivio::Die->die(
	    $attrs->{id},
	    ": can't require_context, because",
	    " FormModel doesn't require it",
	) if !$form_require && $attrs->{require_context};
    }
    else {
	$attrs->{require_context} = $form_require;
    }
    return;
}

sub _invoke_handlers {
    my($method, $req) = @_;
    # Calls $method on the registered handlers.
    foreach my $handler (@_HANDLERS) {
	$handler->$method($req)
	    if $handler->can($method);
    }
    return;
}

sub _parse_map_item {
    my($attrs, $cause, $action) = @_;
    # Parses a new map item for this task.
    return _put_attr(
	$attrs, $cause,
	Bivio::Type::Boolean->from_literal_or_die($action),
    ) if $cause =~ /^(?:require_|want_)[a-z0-9_]+$/;
    $action = $_T->from_any($action);
    return _put_attr($attrs, $cause, $action)
	if $cause =~ /^(?:next|cancel|login|[a-z0-9_]+_task)$/;
    if ($cause =~ /(.+)::(.+)/) {
	my($class, $method) = ($1, $2);
	Bivio::Die->die(
	    $cause, ': not an enum (', $attrs->{id}, ')',
	) unless UNIVERSAL::isa($class, 'Bivio::Type::Enum');
	$cause = $class->from_name($method);
    }
    else {
	Bivio::Die->die($cause, ': not a valid attribute name')
	    unless Bivio::DieCode->is_valid_name($cause);
	$cause = Bivio::DieCode->from_name($cause);
    }
    Bivio::Die->die(
	$cause->get_name, ': cannot be a mapped item (',
	$attrs->{id}, ')',
    ) if $_REDIRECT_DIE_CODES{$cause};
    return _put_attr($attrs, 'die_actions', $cause, $action);
}

sub _put_attr {
    my($attrs, @keys) = @_;
    my($a) = $attrs;
    my($value) = pop(@keys);
    my($final) = pop(@keys);
    foreach my $k (@keys) {
	$a = $a->{$k};
    }
    Bivio::Die->die(
	[@keys, $final], ': attribute already exists for ',
	$attrs->{id},
    ) if defined($a->{$final});
    $a->{$final} = $value;
    return;
}

1;
