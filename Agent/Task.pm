# Copyright (c) 1999-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Task;
use strict;
use Bivio::Base 'Collection.Attributes';

# C<Agent.Task> defines a tuple which is configured by
# L<Agent.TaskId|Agent.TaskId>.
#
# The following fields are returned by L<get|"get">:
#
#
# cancel : Agent.TaskId [next]
#
# The task_id to go to in other cases.  In the case forms, is the "Cancel" task
# of a form.
#
# die_actions : hash_ref (see below for configuration)
#
# The map of die codes (any enums, actually) to tasks executed when
# the die code is encountered for this task.  I<Only maps if the
# request is from HTTP.>
# Specified in L<Agent.TaskId|Agent.TaskId>
# and passed to L<new|"new"> as:
#
#     DIE_CODE=TASK_ID
#
# The name of a L<DieCode|Bivio.DieCode> or a fully
# specified enum, e.g. C<TypeError.EXISTS>.  The action
# will be executed if this enum is thrown.
#
# form_model : Biz.FormModel (computed)
#
# The form model in I<items> or C<undef>.
#
# id : Agent.TaskId (required)
#
# L<Agent.TaskId|Agent.TaskId> for this task.
#
# items : array_ref (required)
#
# A list of actions.  An action is the tuple (singleton instance,
# method name).  When the task is executed, the methods are
# called on the singletons.  If the singleton is undefined,
# it means the method is a subroutine to be called without
# an instance.
#
# next : Agent.TaskId []
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

b_use('IO.Trace');
our($_TRACE);
my($_T) = b_use('Agent.TaskId');
my(%_ID_TO_TASK) = ();
my($_INITIALIZED);
my($_REDIRECT_DIE_CODES) = {
    CLIENT_REDIRECT_TASK => 1,
    SERVER_REDIRECT_TASK => 1,
};
my($_HANDLERS) = [__PACKAGE__];
my($_B) = b_use('Type.Boolean');
my($_PS) = b_use('Auth.PermissionSet');
my($_RT) = b_use('Auth.RealmType');
my($_DC) = b_use('Bivio.DieCode');
my($_A) = b_use('IO.Alert');
my($_S);
my($_C) = b_use('IO.Config');
my($_TE);
our($_COMMITTED) = undef;
our($_IN_COMMIT) = 0;
my($_UNAUTH_EXECUTE) = __PACKAGE__ . '.unauth_execute';
my($_TASK_ATTR_RE) = qr{^(?:next|cancel|login|[a-z0-9_]+_task)$};

sub TASK_ATTR_RE {
    return $_TASK_ATTR_RE;
}

sub assert_realm_type {
    my($self, $realm_type) = @_;
    b_die($realm_type, ': invalid realm_type for ', $self)
        unless $self->has_realm_type($realm_type);
    return;
}

sub commit {
    my(undef, $req) = @_;
    # Commits transactions to storage if necessary, but first calls
    # handle_commit for txn_resources.
    # These modules are intelligent and won't do anything if there
    # were no modifications.
    #
    _call_txn_resources($req, 'handle_commit');
#TODO: Garbage collect state that doesn't agree with SQL DB
    # Note: rollback is in handle_die
    return;
}

sub dep_unsafe_get_attr {
    my($self) = shift;
    return $self->return_scalar_or_array(map($_, $self->SUPER::unsafe_get(@_)));
}

sub execute {
    my($self, $req) = @_;
    local($_COMMITTED) = 0;
    my($next) = $self->execute_items(
	$req,
	[map(_op($self, $_),
	     'handle_pre_auth_task',
	     'handle_pre_execute_task',
	     @{$self->get('items')},
	)],
    );
    _commit($self, $req);
    $next->call_method($req)
	if $next;
    $req->get('reply')->send($req);
    return;
}

sub execute_items {
    my($self, $req, $items) = @_;
    foreach my $i (@{$items || $self->get('items')}) {
	my($instance, $method, $args) = @$i;
	_trace($instance, '->', $method, '(', $args, ')')
	    if $_TRACE;
	next
	    unless my $params
	    = $self->want_scalar($instance->$method(@$args, $req));
	_trace($params)
	    if $_TRACE;
	next
	    unless my $te = $_TE->parse_item_result($params, $self, $req, $i);
	_trace($te)
	    if $_TRACE;
	last
	    unless ref($te);
	return $te;
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

sub get {
    return shift->SUPER::get(@_)
	unless grep($_ =~ $_TASK_ATTR_RE, @_);
    my($self, @keys) = @_;
    $_A->warn_deprecated('use get_attr_as_id or dep_get_attr');
    return $self->return_scalar_or_array(map(
	shift(@_) =~ $_TASK_ATTR_RE && $_ ? $_->{task_id} : $_,
	shift->SUPER::get(@_),
    ));
}

sub get_by_id {
    my(undef, $id) = @_;
    # Returns the task associated with the id.
    $id = $_T->from_name($id)
        unless ref($id);
    b_die($id, ": no task associated with id")
	unless $_ID_TO_TASK{$id};
    return $_ID_TO_TASK{$id};
}

sub dep_get_attr {
    return shift->SUPER::get(@_);
}

sub get_attr_as_id {
    my($self) = shift;
    return $self->return_scalar_or_array(
	map($_->{task_id}, $self->SUPER::get(@_)));
}

sub get_attr_as_task {
    my($proto) = shift;
    return $proto->return_scalar_or_array(
	map($proto->get_by_id($_), $proto->get_attr_as_id(@_)));
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
    my($req_class) = b_use('Agent.Request');
    if ($_REDIRECT_DIE_CODES->{$die_code->get_name}) {
	my($req) = $req_class->get_current_or_die;
	if (my $self = $req->unsafe_get('task')) {
	    _trace('commit: ', $die_code) if $_TRACE;
	    _commit($self, $req);
	}
	return;
    }

    my($req) = $req_class->get_current;
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

    return $_TE->parse_die($die, $proto, $req);
}

sub handle_pre_auth_task {
    my(undef, $task, $req) = @_;
    return
	unless $req->need_to_toggle_secure_agent_execution($task);
    return {
	method => 'client_redirect',
	task_id => $task->get('id'),
	carry_path_info => 1,
	carry_query => 1,
	require_context => 0,
    };
}

sub handle_pre_execute_task {
    my(undef, $task, $req) = @_;
    return
	if $req->unsafe_get_and_delete($_UNAUTH_EXECUTE);
    unless ($req->get('auth_realm')->can_user_execute_task($task, $req)) {
	# make sure the form makes it into the form context
	Bivio::Die->throw_quietly(FORBIDDEN => {
	    map(($_ => $req->get($_)),
		qw(auth_realm auth_user auth_roles auth_role)),
	    operation => $task->get('id'),
	});
    }
    return;
}

sub has_realm_type {
    my($self, $realm_type) = @_;
    return $self->get('_has_realm_type')->{$realm_type};
}

sub in_commit {
    return $_IN_COMMIT;
}

sub initialize {
    my($proto, $partially) = @_;
    # Initializes task list from the configuration in
    # L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.
    #
    # I<partially> allows this module to initialize only part of the
    # task state.  This is only used by L<Bivio::ShellUtil|Bivio::ShellUtil>
    # to speed up command line initialization.  B<Never use in a server.>
    return
	if $_INITIALIZED;
    $_INITIALIZED = 1;
    foreach my $cfg (map(+{%$_}, @{$_T->get_cfg_list})) {
	my($validate) = sub {
	    my($key) = @_;
	    b_die($key, ': missing from ', $cfg)
		unless defined($cfg->{$key});
	    return delete($cfg->{$key});
	};
	my($ps) = $validate->('permission_set');
	delete($cfg->{int});
	$proto->new(
	    $_T->from_any($validate->('name')),
	    $_RT->from_any($validate->('realm_type')),
	    ${$_PS->from_array(
		ref($ps) eq 'ARRAY' ? $ps : [split(/\&/, $ps)],
	    )},
	    $partially ? ()
		: (@{$validate->('items')}, $cfg),
	);
    };
    return;
}

sub internal_as_string {
    return shift->get('id')->get_name;
}

sub new {
    my($proto) = shift;
    my($id, $realm_type, $perm, @items) = @_;
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
    # See L<Bivio::Delegate::TaskId|Bivio::Delegate::TaskId>
    # and L<Bivio::PetShop::Agent::TaskId|Bivio::PetShop::Agent::TaskId>
    # for complete examples.
    #
    # There may only be one FormModel in the items of a task.
    #
    # A mapping item is of the form I<name>=I<action>, where I<name>
    # and I<action> are attributes as defined above.
    $_TE ||= b_use('Agent.TaskEvent');
    b_die("id invalid")
	unless $id->isa($_T);
    b_die("realm_type invalid")
	unless $realm_type->isa('Bivio::Auth::RealmType');
    b_die($id, ': id already defined')
	if $_ID_TO_TASK{$id};
    return _new($proto->SUPER::new, @_);
}

sub put_attr_for_test {
    my($self, @attrs) = @_;
    b_use('Agent.Request')->assert_test;
    $self->internal_clear_read_only;
    $self->do_by_two(
	sub {
	    my($k, $v) = @_;
	    $self->delete($k);
	    if ($k eq 'form_model') {
		$self->put($k => $v->package_name);
	    }
	    else {
		_parse_map_item($self->internal_get, $k, $v);
	    }
	    return 1;
	},
	\@attrs,
    );
    return $self->set_read_only;
}

sub register {
    my($proto, $handler) = @_;
#TODO: Use Biz.Registrar (see _op() - registrar needs to allow iterate handlers)
    push(@$_HANDLERS, $handler)
	unless grep($_ eq $handler, @$_HANDLERS);
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
    return;
}

sub unauth_server_redirect {
    my(undef, $redirect_params, $req) = @_;
    $req->put_durable($_UNAUTH_EXECUTE => 1);
    return $req->server_redirect($redirect_params);
}

sub unsafe_get {
    return shift->SUPER::unsafe_get(@_)
	unless grep($_ =~ $_TASK_ATTR_RE, @_);
    my($self, @keys) = @_;
    $_A->warn_deprecated('use unsafe_get_attr_as_id or dep_unsafe_get_attr');
    return $self->return_scalar_or_array(map(
	shift(@_) =~ $_TASK_ATTR_RE && $_ ? $_->{task_id} : $_,
	shift->SUPER::unsafe_get(@_),
    ));
}

sub unsafe_get_attr_as_id {
    my($self) = shift;
    return $self->return_scalar_or_array(
	map($_ && $_->{task_id}, $self->SUPER::unsafe_get(@_)));
}

sub unsafe_get_redirect {
    my($self, $attr, $req) = @_;
    # Returns the task associated with I<attr> on I<self>, if it exists and is
    # defined in the facade.
    b_die($attr, ': invalid task attribute; must match ', $_TASK_ATTR_RE)
	unless $attr =~ $_TASK_ATTR_RE;
    return undef
	unless my $v = $self->dep_unsafe_get_attr($attr);
    return b_use('FacadeComponent.Task')->is_defined_for_facade($v->{task_id}, $req)
	? $v : undef;
}

sub unsafe_params_for_die_code {
    return shift->get('die_actions')->{shift(@_)->get_name};
}

sub _call_txn_resources {
    my($req, $method) = @_;
    return
	unless $req;
    my($resources) = [@{$req->unsafe_get('txn_resources') || []}];
    my($orig_die);
    _call_txn_resources_method(
	$resources, 'handle_prepare_commit', $req, \$orig_die,
    ) if $method eq 'handle_commit';
    $method = 'handle_rollback'
	if $orig_die;
    local($_IN_COMMIT) = $method eq 'handle_commit' ? 1 : 0;
    $resources = $req->unsafe_get('txn_resources') || [];
    $req->put(txn_resources => []);
    _call_txn_resources_method($resources, $method, $req, \$orig_die);
    $orig_die->throw
	if $orig_die;
    return;
}

sub _call_txn_resources_method {
    my($resources, $method, $req, $orig_die) = @_;
    foreach my $r (reverse(@$resources)) {
	_trace($r, '->', $method) if $_TRACE;
	next
	    unless my $die = Bivio::Die->catch(
		sub {
		    $r->$method($req)
			if $r->can($method);
		    return;
		},
	    );
	$$orig_die ||= $die
	    if $method ne 'handle_rollback';
	last
	    if $method eq 'handle_prepare_commit';
	b_warn($r, '->', $method, ': ', $die, '; switching to rollback');
	$method = 'handle_rollback';
    }
    return;
}

sub _commit {
    my($self, $req) = @_;
    return b_warn('$_COMMITTED is not defined')
	unless defined($_COMMITTED);
    return
	if $_COMMITTED++;
    # handle_post_execute_task cannot override $next (unlike other handlers)
    $self->execute_items($req, [_op($self, 'handle_post_execute_task')]);
    $self->commit($req);
    return;
}

sub _extra_auth {
    my($attrs, $method) = @_;
    $method = "extra_auth_$method";
    b_die(b_use('Auth.Support'), '->', $method, ': not implemented; ', $attrs)
	unless b_use('Auth.Support')->b_can($method);
    return $method;
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
	$_C->if_version(8 => 0, sub {
	    $c = $c->get_instance
		if $c->b_can('get_instance');
	    return;
	});
	if ($c->b_can('execute_task_item') && $method) {
	    push(@new_items, [$c, execute_task_item => [$method]]);
	}
	else {
	    $method ||= 'execute';
	    b_die($i, ": can't be executed (missing $method method)")
	        unless $c->b_can($method) || $c->b_can('AUTOLOAD');
	    push(@new_items, [$c, $method, []]);
	}
	if ($c->isa('Bivio::Biz::FormModel')) {
	    b_die($attrs->{id}, ': too many form models')
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

    b_die($attrs->{id}, ": FormModels require \"next=\" item")
	unless $attrs->{next};
    # default cancel to next unless present
    $attrs->{cancel} = $attrs->{next} unless $attrs->{cancel};

    my($form_require) = $attrs->{form_model}->get_instance
	->get_info('require_context');
    if (defined($attrs->{require_context})) {
	b_die(
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

sub _new {
    my($self, $id, $realm_type, $perm, @items) = @_;
    my($attrs) = {
	id => $id,
	realm_type => $realm_type,
	permission_set => $perm,
	die_actions => {},
	form_model => undef,
    };
    # Make the task visible to the items being initialized
    $_ID_TO_TASK{$id} = $self;
    my(@executables);
    foreach my $i (@items) {
	if (ref($i) eq 'HASH') {
	    map(_parse_map_item($attrs, $_, $i->{$_}), sort(keys(%$i)));
	    next;
	}
	elsif (ref($i) eq 'ARRAY' || $i =~ /=/ && ($i = [split(/=/, $i, 2)])) {
	    _parse_map_item($attrs, @$i);
	    next;
	}
	push(@executables, $i);
    }
    my($new_items) = _init_executables($self, $attrs, \@executables);
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
    $attrs->{_has_realm_type} = {
	map(($_ => $_->equals_or_any_owner_check($realm_type)),
	    $_RT->get_list,
	),
    };
    $self->internal_put($attrs);
    return $self->set_read_only;
}

sub _op {
    my($self, $item) = @_;
    return ref($item) ? $item
	: map($_->b_can($item) ? [$_, $item, [$self]] : (),
	      $item eq 'handle_post_execute_task'
		  ? reverse(@$_HANDLERS) : @$_HANDLERS),
}

sub _parse_map_item {
    my($attrs, $cause, $params) = @_;
    foreach my $x (
	[qr{^(?:require_|want_)[a-z0-9_]+$}, sub {$_B->from_literal_or_die($params)}],
	[qr{^attr_[a-z0-9_]+$}, sub {$params}],
	[qr{^extra_auth$}, sub {_extra_auth($attrs, $params)}],
	[$_TASK_ATTR_RE, sub {$_TE->parse_item($cause, $params)}],
    ) {
	return _put_attr($attrs, $cause, $x->[1]->())
	    if $cause =~ $x->[0];
    }
    my($p) = $_TE->parse_item($cause, $params);
    b_die($cause, ': value must be a task_id: ', $params)
	unless $p->{task_id};
    return _put_attr($attrs->{die_actions}, $_DC->from_name($cause)->get_name, $p);
}

sub _put_attr {
    my($attrs, $key, $value) = @_;
    b_die($key, ': attribute already exists for ', $attrs->{id})
	if defined($attrs->{$key});
    $attrs->{$key} = $value;
    return;
}

1;
