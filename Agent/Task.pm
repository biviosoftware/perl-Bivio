# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Task;
use strict;
$Bivio::Agent::Task::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::Task - defines the tuple (id, @items)

=head1 SYNOPSIS

    use Bivio::Agent::Task;
    Bivio::Agent::Task->initialize();
    Bivio::Agent::Task->new($id, @items);
    $task->get('id');
    $task->get('next');
    $task->execute($req)

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

=item cancel

The task_id to go to in other cases. Not required.

=item die_actions

The map of die codes (any enums, actually) to tasks executed when
the die code is encountered for this task.  I<Only maps if the
request is from HTTP.>

=item form_model

The form model in I<items> or C<undef>.

=item id

L<Bivio::Agent::TaskId|Bivio::Agent::TaskId> for this task.

=item items

A list of actions.  An action is the tuple (singleton instance,
method name).  When the task is executed, the methods are
called on the singletons.  If the singleton is undefined,
it means the method is a subroutine to be called without
an instance.

=item next

The next task_id to go to in certain cases.  Not always
defined.

=item permission_set

L<Bivio::Auth::Permission|Bivio::Auth::PermissionSet> for this task.

=item realm_type

L<Bivio::Auth::RealmType|Bivio::Auth::RealmType> for this task.

=item require_context

The I<form_model> has C<require_context> defined.

=back

=cut


=head1 CONSTANTS

=cut

=for html <a name="DEFAULT_HELP"></a>

=head2 DEFAULT_HELP : string

This is the path_info for the default help file.

=cut

sub DEFAULT_HELP {
    return '/index.html';
}

#=IMPORTS
use Bivio::Die;
use Bivio::IO::Trace;
use Bivio::Agent::TaskId;
use Bivio::Collection::SingletonMap;
use Bivio::DieCode;
use Bivio::Mail::Common;
use Bivio::Mail::Message;
use Bivio::SQL::Connection;
# use Bivio::Agent::Job::Dispatcher;
use Carp ();


#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my(%_ID_TO_TASK) = ();
my($_INITIALIZED);
my(%_REDIRECT_DIE_CODES) = (
    Bivio::DieCode::CLIENT_REDIRECT_TASK() => 1,
    Bivio::DieCode::SERVER_REDIRECT_TASK() => 1,
);

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

=item cancel

the "Cancel" task of a form.  If not specified, defaults to
the I<next> task.

=item help

The name of the help file for this task.

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

    # If there is an error, we'll be caching instances in one of the
    # hashes which may never be used.  Unlikely we'll be continuing after
    # the error anyway...
    my($attrs) = {
	id => $id,
	realm_type => $realm_type,
	permission_set => $perm,
	die_actions => {},
	form_model => undef,
    };
    foreach $i (@items) {
	if ($i =~ /=/) {
	    # Map item
	    _parse_map_item($attrs, split(/=/, $i, 2));
	    next;
	}
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
	    Bivio::Die->die($id->as_string, ': too many form models')
			if $attrs->{form_model};
	    $attrs->{form_model} = $class;
	}
	push(@new_items, [$c, $method]);
    }

    # Set form
    if ($attrs->{form_model}) {
	Carp::croak($id->as_string, ": FormModels require \"next=\" item")
		    unless $attrs->{next};
	$attrs->{require_context} = $attrs->{form_model}->get_instance
		->get_info('require_context');
	# default cancel to next unless present
	$attrs->{cancel} = $attrs->{next} unless $attrs->{cancel};
    }
    else {
	$attrs->{require_context} = 0;
    }

    # If there is an error, we'll be caching instances in one of the
    # hashes which may never be used.  Unlikely we'll be continuing after
    # the error anyway...
    $attrs->{items} = \@new_items;
    my($self) = &Bivio::Collection::Attributes::new($proto, $attrs);
    $self->set_read_only;
    return $_ID_TO_TASK{$id} = $self;
}

=head1 METHODS

=cut

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
    my($auth_realm, $auth_role) = $req->get('auth_realm', 'auth_role');
#TODO: Handle multiple realms and roles.  Switching between should be possible.
    unless ($auth_realm->can_user_execute_task($self, $req)) {
	my($auth_user) = $req->get('auth_user');
	Bivio::Die->throw('FORBIDDEN',
		{auth_user => $auth_user, entity => $auth_realm,
		    auth_role => $auth_role, operation => $attrs->{id}})
		    if $auth_user;
	$req->server_redirect(Bivio::Agent::TaskId::LOGIN());
	# DOES NOT RETURN
    }
    my($i);
    foreach $i (@{$attrs->{items}}) {
	my($instance, $method) = @$i;
	# Don't continue if returns true.
	last if defined($instance) ? $instance->$method($req) : &$method($req);
    }
    _commit($req);
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
    if ($_REDIRECT_DIE_CODES{$die_code}) {
	# commit redirects: current task is completed
	_commit(Bivio::Agent::Request->get_current);
	return;
    }

    # Some type of unhandled error.  Rollback and check die_actions
    $proto->rollback;
    return unless ref($proto);

    # Is this an HTTP request? (We don't redirect on non-http requests)
    my($req) = Bivio::Agent::Request->get_current;
    return unless UNIVERSAL::isa($req, 'Bivio::Agent::HTTP::Request');

    # Mapped?
    my($new_task_id) = $proto->get('die_actions')->{$die_code};
    unless (defined($new_task_id)) {
	# Default mapped?
	$new_task_id = Bivio::Agent::TaskId->unsafe_from_any(
		'DEFAULT_ERROR_REDIRECT_'.$die_code->get_name);
	return unless defined($new_task_id);
    }

    # Redirected
    # This is enough tracing, because the dispatcher describes the transition
    _trace('mapped server redirect from ', $die_code) if $_TRACE;
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
    return if $_INITIALIZED;
    my($cfg) = Bivio::Agent::TaskId->get_cfg_list;
    map {
	my($id_name, undef, $realm_type, $perm_spec, undef, @items) = @$_;
	my($perm_set) = Bivio::Auth::PermissionSet->get_min;
	foreach my $p (split(/\&/, $perm_spec)) {
	    Bivio::Auth::PermissionSet->set(\$perm_set,
		    Bivio::Auth::Permission->$p());
	}
	Bivio::Agent::Task->new(Bivio::Agent::TaskId->$id_name(),
		Bivio::Auth::RealmType->$realm_type(),
		$perm_set, @items);
    } @$cfg;
    $_INITIALIZED = 1;
    return;
}

=for html <a name="rollback"></a>

=head2 rollback()

Rollback the current transaction.  Call C<handle_rollback> with
L<txn_resources|"txn_resources">.  Clears any queued mail.

Called from L<Bivio::Biz::FormModel|Bivio::Biz::FormModel>.

=cut

sub rollback {
    # NOTE: Bivio::Biz::Model::Lock::release behaves a particular way
    # and this code must stay in synch with it.
    my($req) = Bivio::Agent::Request->get_current;
    _call_txn_resources($req, 'handle_rollback');
    Bivio::SQL::Connection->rollback;
    Bivio::Mail::Common->discard_queued_messages;
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

# _commit(Bivio::Agent::request req)
#
# Commits transactions to storage if necessary, but first calls
# handle_commit for txn_resources.
#
sub _commit {
    my($req) = @_;
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
    Bivio::Mail::Message->send_queued_messages;
#TODO: Garbage collect state that doesn't agree with SQL DB
    # Note: rollback is in handle_die
    return;
}

# _parse_map_item(hash_ref attrs, string cause, string action)
#
# Parses a new map item for this task.
#
sub _parse_map_item {
    my($attrs, $cause, $action) = @_;

    if ($cause eq 'help') {
	Bivio::Die->die($attrs->{id}, ': invalid help=', $action)
		unless $action =~ /^[\w-]+$/;
#TODO: This presumes a lot.  Too much?
	$attrs->{help} = '/'.$action.'.html';
	Bivio::Die->die($attrs->{id}, ': help file not found: ',
		$attrs->{help}) unless
			-r Bivio::Agent::HTTP::Location->get_help_root()
				.$attrs->{help};
	return;
    }

    # These items all have tasks as actions
    $action = Bivio::Agent::TaskId->from_any($action);

    if ($cause =~ /^(?:next|cancel)$/) {
	# Special cases (non-enums)
	$attrs->{$cause} = $action;
	return;
    }

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
    Carp::croak($cause->get_name, ': cannot be a mapped item (',
	    $attrs->{id}->as_string, ')')
		if $_REDIRECT_DIE_CODES{$cause};
    $attrs->{die_actions}->{$cause} = $action;
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
