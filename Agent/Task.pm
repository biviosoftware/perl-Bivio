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

use Bivio::UNIVERSAL;
@Bivio::Agent::Task::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Agent::Task> defines a tuple which is configured by
L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.

The following fields are returned by L<get|"get">:

=over 4

=item id

L<Bivio::Agent::TaskId|Bivio::Agent::TaskId> for this task.

=item items

A list of classes which have an C<execute> method.

=item next

The next task_id to go to in certain cases.  Not always
defined.

=back

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Collection::SingletonMap;
use Bivio::DieCode;
use Bivio::Mail::Common;
use Bivio::SQL::Connection;
use Carp ();


#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my(%_ID_TO_TASK) = ();
my($_INITIALIZED);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::TaskId id, any item1, ...) : Bivio::Agent::Task

Creates a new task for I<id>.  A task must not already be
bound to the I<id>.   The rest of the arguments are
items to be executed (in order).

=cut

sub new {
    my($proto, $id, @items) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    die("id invalid") unless $id->isa('Bivio::Agent::TaskId');
    die($id->as_string, ': id already defined') if $_ID_TO_TASK{$id};
    my($i, $next, @new_items);
    # If there is an error, we'll be caching instances in one of the
    # hashes which may never be used.  Unlikely we'll be continuing after
    # the error anyway...
    my($fields) = $self->{$_PACKAGE} = {
	'id' => $id,
    };
    my($have_form) = 0;
    foreach $i (@items) {
	if ($i =~ /^(next)=(\w+)$/) {
	    $fields->{$1} = Bivio::Agent::TaskId->from_any($2);
	}
	else {
	    my($c) = Bivio::Collection::SingletonMap->get($i);
	    Carp::croak($i, ": can't be executed") unless $c->can('execute');
	    $have_form++ if $c->isa('Bivio::Biz::FormModel');
	    push(@new_items, $c);
	}
    }
    Carp::croak($id->as_string, ": FormModels require \"next=\" item")
		if $have_form && !$fields->{next};
    # If there is an error, we'll be caching instances in one of the
    # hashes which may never be used.  Unlikely we'll be continuing after
    # the error anyway...
    $fields->{items} = \@new_items;
    return $_ID_TO_TASK{$id} = $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Executes the task for the specified request.  Checks that the request is
authorized.  Calls C<commit> and C<send_queued_messages> if there is an action.
Calls C<reply->flush>.

B<Must be called within L<Bivio::Die::catch|Bivio::Die/"catch">.> Depends on
the fact that L<handle_die|"handle_die"> is called to execute rollback.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($auth_realm, $auth_role) = $req->get('auth_realm', 'auth_role');
#TODO: Handle multiple realms and roles.  Switching between should be possible.
    unless ($auth_realm->can_role_execute_task($auth_role, $fields->{id})) {
	my($auth_user) = $req->get('auth_user');
#	Bivio::Die->die($auth_user ? 'FORBIDDEN' : 'AUTH_REQUIRED',
	Bivio::Die->die('AUTH_REQUIRED',
		{auth_user => $auth_user, entity => $auth_realm,
		    auth_role => $auth_role, operation => $fields->{id}});
    }
    my($i);
    foreach $i (@{$fields->{items}}) {
	$i->execute($req);
    }
    # Always commit before sending queued messages.  The database
    # is more important than email.  If we get an error
    # while rendering view, don't commit since the only side effect
    # is that there might be some external state outside of SQL DB
    # which needs to be garbage-collected.
    #
    # These modules are intelligent and won't do anything if there
    # were no modifications.
    Bivio::SQL::Connection->commit;
    Bivio::Mail::Common->send_queued_messages;
#TODO: Garbage collect state that doesn't agree with SQL DB
    # Note: rollback is in handle_die
    $req->get('reply')->flush;
    return;
}

=for html <a name="get"></a>

=head2 get(string attr, ...) : (any, ...)

Returns the list of attributes specified.

=cut

sub get {
    my($fields) = shift->{$_PACKAGE};
    return map {
	Carp::croak("$_: no such attribute for ", $fields->{id}->as_string)
		unless exists($fields->{$_});
	$fields->{$_};
    } @_;
}

=for html <a name="get_by_id"></a>

=head2 static get_by_id(Bivio::Agent::TaskId id) : Bivio::Agent::Task

Returns the task associated with the id.

=cut

sub get_by_id {
    my(undef, $id) = @_;
    Carp::croak($id->as_string, ": no task associated with id")
	    unless $_ID_TO_TASK{$id};
    return $_ID_TO_TASK{$id};
}

=for html <a name="handle_die"></a>

=head2 handle_die(Bivio::Die die)

Something happened while executing a request, so we have to rollback
and discard the mail queue unless is a REDIRECT_TASK.

=cut

sub handle_die {
    my($proto, $die) = @_;
    return if $die->get('code') == Bivio::DieCode::REDIRECT_TASK();
    $proto->rollback;
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
	my(@items) = @$_;
	my($id_name) = shift(@items);
	splice(@items, 0, 4);
	Bivio::Agent::Task->new(Bivio::Agent::TaskId->$id_name(), @items);
    } @$cfg;
    $_INITIALIZED = 1;
    return;
}

=for html <a name="rollback"></a>

=head2 rollback()

Rollback an transactions.

Called from L<Bivio::Biz::FormModel|Bivio::Biz::FormModel>.

=cut

sub rollback {
#TODO: Need to undo mkdir or writes in MailMessage.  Probably push on stack of
#      commit handlers...??
    Bivio::SQL::Connection->rollback;
    Bivio::Mail::Common->discard_queued_messages;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
