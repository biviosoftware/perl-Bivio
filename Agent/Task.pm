# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Task;
use strict;
$Bivio::Agent::Task::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Agent::Task::VERSION;

=head1 NAME

Bivio::Agent::Task - defines the tuple (id, @items)

=head1 SYNOPSIS

    use Bivio::Agent::Task;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Agent::Task::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Agent::Task> defines a tuple which is configured by
L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.

The following fields are returned by L<get|"get">:

=over 4

=item cancel : Bivio::Agent::TaskId [next]

The task_id to go to in other cases.

=item die_actions : hash_ref

The map of die codes (any enums, actually) to tasks executed when
the die code is encountered for this task.  I<Only maps if the
request is from HTTP.>

=item form_model : Bivio::Biz::FormModel (computed)

The form model in I<items> or C<undef>.

=item id : Bivio::Agent::TaskId|Bivio::Agent::TaskId (required)

L<Bivio::Agent::TaskId|Bivio::Agent::TaskId> for this task.

=item items : array_ref (required)

A list of actions.  An action is the tuple (singleton instance,
method name).  When the task is executed, the methods are
called on the singletons.  If the singleton is undefined,
it means the method is a subroutine to be called without
an instance.

=item next : Bivio::Agent::TaskId []

The next task_id to go to in certain cases.  Required only if
there is a FormModel in I<items>.

=item permission_set : Bivio::Auth::Permission (required)

L<Bivio::Auth::Permission|Bivio::Auth::PermissionSet> for this task.

=item realm_type : Bivio::Auth::RealmType (required)

L<Bivio::Auth::RealmType|Bivio::Auth::RealmType> for this task.

=item require_context : boolean [form_model's require_context]

The I<form_model> has C<require_context> defined, unless
overriden by the configuration.  You can't turn on I<require_context>
if the I<form_model> doesn't require it already.

=item want_query : boolean [1]

L<Bivio::Agent::Request|Bivio::Agent::Request> will not add the query
(even if supplied) if this is false.

=item require_secure : boolean [0]

Task must be in secure mode to function.

=back

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Auth::PermissionSet;
use Bivio::Auth::RealmType;
use Bivio::Collection::SingletonMap;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;
use Bivio::Mail::Common;
use Bivio::Mail::Message;
use Bivio::SQL::Connection;
use Bivio::Type::Boolean;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my(%_ID_TO_TASK) = ();
my($_INITIALIZED);
my(%_REDIRECT_DIE_CODES) = (
    Bivio::DieCode::CLIENT_REDIRECT_TASK() => 1,
    Bivio::DieCode::SERVER_REDIRECT_TASK() => 1,
);
my($_REQUEST_LOADED);
my(@_HANDLERS);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::TaskId id, Bivio::Auth::RealmType realm_type, string perm, any item1, ...) : Bivio::Agent::Task

Creates a new task for I<id> with I<perm> and I<realm_type>.
A task must not already be
bound to the I<id>.   The rest of the arguments are
items to be executed (in order) or mapped.  An executable item must be a
class with an C<execute> method, of the form C<class-E<gt>method>,
or a C<CODE> reference, i.e. a C<sub> which takes a C<$req> as
a parameter.

There may only be one FormModel in the items of a task.

A mapping item is of the form I<name>=I<action>, where I<name>
and I<action> are mapped as follows:

=over 4

=item cancel : string

The "Cancel" task of a form.  If not specified, defaults to
the I<next> task.

=item next

identifies "OK" task of a form.  All tasks which have an
L<Bivio::Biz::FormModel|Bivio::Biz::FormModel> as an executable
item, must have a I<next>.

=item I<DIE_CODE>

The name of a L<Bivio::DieCode|Bivio::DieCode> or a fully
specified enum, e.g. C<Bivio::TypeError::EXISTS>.  The action
will be executed if this enum is thrown.

=back

=cut

sub new {
    my($proto, $id, $realm_type, $perm, @items) = @_;

    # Validate $id
    die("id invalid") unless $id->isa('Bivio::Agent::TaskId');
    die("realm_type invalid")
	    unless $realm_type->isa('Bivio::Auth::RealmType');
    die($id->as_string, ': id already defined') if $_ID_TO_TASK{$id};
    my($i, $next, @new_items);

    my($self) = Bivio::Collection::Attributes::new($proto, {
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
    foreach $i (@items) {
	if ($i =~ /=/) {
	    # Map item
	    _parse_map_item($attrs, split(/=/, $i, 2));
	    next;
	}
	push(@executables, $i);
    }
    my($new_items) = _init_executables($attrs, \@executables);
    # Set form
    _init_form_attrs($attrs);

    # Defaults
    $attrs->{want_query} = 1 unless defined($attrs->{want_query});
    $attrs->{require_secure} = 0 unless defined($attrs->{require_secure});

    # If there is an error, we'll be caching instances in one of the
    # hashes which may never be used.  Unlikely we'll be continuing after
    # the error anyway...
    $attrs->{items} = $new_items;
    $self->set_read_only;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="commit"></a>

=head2 static commit(Bivio::Agent::request req)

Commits transactions to storage if necessary, but first calls
handle_commit for txn_resources.

=cut

sub commit {
    my(undef, $req) = @_;
    # Always commit before sending queued messages.  The database
    # is more important than email and mail dispatcher may need the
    # state to accurately send the email.  If we get an error
    # while rendering view, don't commit since the only side effect
    # is that there might be some external state outside of SQL DB
    # which needs to be garbage-collected.
    #
    # These modules are intelligent and won't do anything if there
    # were no modifications.
    #
    _call_txn_resources($req, 'handle_commit');
    Bivio::SQL::Connection->commit;
    Bivio::Mail::Common->send_queued_messages;
    Bivio::Mail::Message->send_queued_messages($req);
#TODO: Garbage collect state that doesn't agree with SQL DB
    # Note: rollback is in handle_die
    return;
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Executes the task for the specified request.  Checks that the request is
authorized.  Calls C<commit> and C<send_queued_messages> if there is an action.
Calls C<reply-E<gt>send>.

If I<execute> returns true, stops item execution.

B<Must be called within L<Bivio::Die::catch|Bivio::Die/"catch">.> Depends on
the fact that L<handle_die|"handle_die"> is called to execute rollback.

=cut

sub execute {
    my($self, $req) = @_;
    my($attrs) = $self->internal_get;
    $req->client_redirect_if_not_secure() if $self->get('require_secure');
    my($auth_realm, $auth_role) = $req->get('auth_realm', 'auth_role');
#TODO: Handle multiple realms and roles.  Switching between should be possible.
    unless ($auth_realm->can_user_execute_task($self, $req)) {
	my($auth_user, $agent) = $req->get(
		'auth_user', 'Bivio::Type::UserAgent');
	# Redirect to FORBIDDEN if not browser or not auth_user
	Bivio::Die->throw('FORBIDDEN',
		{auth_user => $auth_user, entity => $auth_realm,
		    auth_role => $auth_role, operation => $attrs->{id}})
		    if $auth_user || !$agent->is_browser;
	$req->server_redirect(Bivio::Agent::TaskId::LOGIN());
	# DOES NOT RETURN
    }
    _invoke_pre_execute_handlers($req);
    my($i);
    foreach $i (@{$attrs->{items}}) {
	my($instance, $method) = @$i;
	# Don't continue if returns true.
	last if defined($instance) ? $instance->$method($req) : &$method($req);
    }
    $self->commit($req);
    $req->get('reply')->send($req);
    return;
}

=for html <a name="get_by_id"></a>

=head2 static get_by_id(Bivio::Agent::TaskId id) : Bivio::Agent::Task

Returns the task associated with the id.

=cut

sub get_by_id {
    my(undef, $id) = @_;
    Bivio::Die->die($id, ": no task associated with id")
		unless $_ID_TO_TASK{$id};
    return $_ID_TO_TASK{$id};
}

=for html <a name="handle_die"></a>

=head2 static handle_die(Bivio::Die die)

Something happened while executing a request, so we have to rollback
and discard the mail queue unless is a <tt>CLIENT_REDIRECT_TASK</tt>
or <tt>SERVER_REDIRECT_TASK</tt>.

If I<proto> is a reference which can map the I<die> code in
one of its I<die_actions> (cannot be redirect code) if the
request is from HTTP.

The die code is converted to <tt>SERVER_REDIRECT_TASK</tt>
with the mapped die_action set as its I<task_id> attribute.

If no specific I<die_action> is found, the C<DEFAULT_ERROR_REDIRECT_>
task id is sought.

=cut

sub handle_die {
    my($proto, $die) = @_;
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
    $req->warn('task_error=', $die) if $req;

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
	$new_task_id = Bivio::Agent::TaskId->unsafe_from_any(
		'DEFAULT_ERROR_REDIRECT_'.$die_code->get_name);
	unless (defined($new_task_id)) {
	    _trace('not a mapped task: ', $die_code) if $_TRACE;
	    return;
	}
	unless (Bivio::UI::Task->is_defined_for_facade($new_task_id, $req)) {
	    _trace('error redirect not defined in facade: ', $new_task_id)
		    if $_TRACE;
	    return;
	}
    }

    # Redirect to error redirect
    $die->set_code(Bivio::DieCode::SERVER_REDIRECT_TASK(),
	    task_id => $new_task_id);
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes task list from the configuration in
L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.

=cut

sub initialize {
    my($proto) = @_;
    return if $_INITIALIZED;
    $_INITIALIZED = 1;

    foreach my $cfg (@{Bivio::Agent::TaskId->get_cfg_list}) {
	my($id_name, undef, $realm_type, $perm_spec, @items) = @$cfg;
	my($perm_set) = Bivio::Auth::PermissionSet->get_min;
	foreach my $p (split(/\&/, $perm_spec)) {
	    Bivio::Auth::PermissionSet->set(\$perm_set,
		    Bivio::Auth::Permission->$p());
	}
	$proto->new(Bivio::Agent::TaskId->$id_name(),
		Bivio::Auth::RealmType->$realm_type(),
		$perm_set, @items);
    };
    return;
}

=for html <a name="register"></a>

=head2 static register(proto handler)

Registers a pre execution handler if not already registered. The I<handler>
must support L<handle_pre_execute_task|"handle_pre_execute_task">.

=cut

sub register {
    my($proto, $handler) = @_;
    return if grep($_ eq $handler, @_HANDLERS);
    push(@_HANDLERS, $handler);
    return;
}

=for html <a name="rollback"></a>

=head2 rollback(Bivio::Agent::Request req)

Rollback the current transaction.  Call C<handle_rollback> with
L<txn_resources|"txn_resources">.  Clears any queued mail.

Called from L<Bivio::Biz::FormModel|Bivio::Biz::FormModel>.

=cut

sub rollback {
    my(undef, $req) = @_;
    # NOTE: Bivio::Biz::Model::Lock::release behaves a particular way
    # and this code must stay in synch with it.
    _call_txn_resources($req, 'handle_rollback');
    Bivio::SQL::Connection->rollback;
    Bivio::Mail::Common->discard_queued_messages;
    Bivio::Mail::Message->discard_queued_messages;
    return;
}

#=PRIVATE METHODS

# _call_txn_resources(Bivio::Agent::Request req, string method) 
#
# Call the transaction resource handlers.
#
sub _call_txn_resources {
    my($req, $method) = @_;
    return unless $req;
    my($resources) = $req->unsafe_get('txn_resources');
    if (ref($resources) eq 'ARRAY') {
	foreach my $r (@$resources) {
	    _trace($r, '->', $method) if $_TRACE;
	    $r->$method();
	}
    }

    # Empty the list
    $req->put(txn_resources => []);
    return;
}

# _init_executables(hash_ref attrs, array_ref executables) : array_ref
#
# Returns the parsed and initialized executables.
#
sub _init_executables {
    my($attrs, $executables) = @_;
    my(@new_items);
    foreach my $i (@$executables) {
	if (ref($i) eq 'CODE') {
	    push(@new_items, [undef, $i]);
	    next;
	}

	# Executable item
	my($class, $method) = split(/->/, $i, 2);
	my($c) = Bivio::Collection::SingletonMap->get($class);
	$method ||= 'execute';
	Bivio::Die->die($i,
		": can't be executed (missing $method method)")
		    unless $c->can($method);
	if ($c->isa('Bivio::Biz::FormModel')) {
	    Bivio::Die->die($attrs->{id}, ': too many form models')
			if $attrs->{form_model};
	    $attrs->{form_model} = $class;
	}
	push(@new_items, [$c, $method]);
    }
    return \@new_items;
}

# _init_form_attrs(hash_ref attrs)
#
# Initializes the form_model attributes.
#
sub _init_form_attrs {
    my($attrs) = @_;
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
	Bivio::Die->die($attrs->{id}, ": can't require_context, because",
		" FormModel doesn't require it")
		    if !$form_require && $attrs->{require_context};
    }
    else {
	$attrs->{require_context} = $form_require;
    }
    return;
}

# _invoke_pre_execute_handlers(Bivio::Agent::Request req)
#
# Calls the L<handle_pre_execute_task|"handle_pre_execute_task"> method
# on all the registered handlers.
#
sub _invoke_pre_execute_handlers {
    my($req) = @_;
    foreach my $handler (@_HANDLERS) {
	$handler->handle_pre_execute_task($req);
    }
    return;
}

# _parse_map_item(hash_ref attrs, string cause, string action)
#
# Parses a new map item for this task.
#
sub _parse_map_item {
    my($attrs, $cause, $action) = @_;

    return _put_attr($attrs, $cause,
	    Bivio::Type::Boolean->from_literal_or_die($action))
	    if $cause =~ /^(?:require_context|want_query|require_secure)$/;

    # These items all have tasks as actions
    $action = Bivio::Agent::TaskId->from_any($action);

    # Special cases (non-enums)
    return _put_attr($attrs, $cause, $action)
	    if $cause =~ /^(?:next|cancel|login)$/;

    # Map die action
    if ($cause =~ /(.+)::(.+)/) {
	# Fully specified enum
	my($class, $method) = ($1, $2);
	Bivio::Die->die($cause, ': not an enum (', $attrs->{id}, ')')
		    unless UNIVERSAL::isa($class, 'Bivio::Type::Enum');
	$cause = $class->from_name($method);
    }
    else {
	# Must be a DieCode
	$cause = Bivio::DieCode->from_name($cause);
    }
    Bivio::Die->die($cause->get_name, ': cannot be a mapped item (',
	    $attrs->{id}, ')')
		if $_REDIRECT_DIE_CODES{$cause};
    return _put_attr($attrs, 'die_actions', $cause, $action);
}

# _put_attr(hash_ref attrs, string key, ..., any value)
#
#
sub _put_attr {
    my($attrs, @keys) = @_;
    my($a) = $attrs;
    my($value) = pop(@keys);
    my($final) = pop(@keys);
    foreach my $k (@keys) {
	$a = $a->{$k};
    }
    Bivio::Die->die([@keys, $final], ': attribute already exists for ',
	    $attrs->{id}) if defined($a->{$final});
    $a->{$final} = $value;
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
