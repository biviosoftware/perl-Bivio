# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Task;
use strict;
$Bivio::Agent::Task::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::Task - defines the tuple (id, action, and view)

=head1 SYNOPSIS

    use Bivio::Agent::Task;
    Bivio::Agent::Task->new($id, $action, $model1, $view, $model2);
    $task->get('id', 'action', 'view');
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

=item action

=item view

=back

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Biz::Action;
use Bivio::Biz::Model;
use Bivio::Mail::Common;
use Bivio::SQL::Connection;
use Bivio::UI::View;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my(%_ID_TO_TASK) = ();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::TaskId id, string action_class, string view) : Bivio::Agent::Task

Creates a new task for I<id>.  A task must not already be
bound to the I<id>.   The rest of the arguments are
objects.

=cut

sub new {
    my($proto, $id, $action_class, $view) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    die("id invalid")
	    unless $id->isa('Bivio::Agent::TaskId');
    $action_class || ref($view)
	    || die($id->as_string, ': neither action or view is defined');
    die($id->as_string, ': action is not a Bivio::Biz::Action')
	    unless !defined($action_class)
		    || $action_class->isa('Bivio::Biz::Action');
    die($id->as_string, ': view is not a Bivio::UI::View')
	    unless !defined($view) || $view->isa('Bivio::UI::View');
    $_ID_TO_TASK{$id} && die($id->as_string, ': id already defined');
    # If there is an error, we'll be caching instances in one of the
    # hashes which may never be used.  Unlikely we'll be continuing after
    # the error anyway...
    $self->{$_PACKAGE} = {
	'id' => $id,
	'action_class' => $action_class,
	'view' => $view,
    };
    return $_ID_TO_TASK{$id} = $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Executes the task for the specified request.

B<Must be called within L<Bivio::Die::catch|Bivio::Die/"catch">.>

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{action_class} && $fields->{action_class}->execute($req);
    $fields->{view} && $fields->{view}->execute($req);
    if ($fields->{action_class}) {
	# Always commit before sending queued messages.  The database
	# is more important than email.  If we get an error
	# while rendering view, don't commit since the only side effect
	# is that there might be some external state outside of SQL DB
	# which needs to be garbage-collected.
	Bivio::SQL::Connection->commit();
	Bivio::Mail::Common->send_queued_messages;
#TODO: Garbage collect state that doesn't agree with SQL DB
    }
    # Note rollback is in handle_die
    return;
}

=for html <a name="get"></a>

=head2 get(string attr, ...) : (any, ...)

Returns the list of attributes specified.

=cut

sub get {
    my($fields) = shift->{$_PACKAGE};
    return map {
	exists($fields->{$_}) || die("$_: no such attribute");
	$fields->{$_}
    } @_;
}

=for html <a name="get_by_id"></a>

=head2 static get_by_id(Bivio::Agent::TaskId id) : Bivio::Agent::Task

Returns the task associated with the id.

=cut

sub get_by_id {
    my(undef, $id) = @_;
    die($id->as_string, ": no task associated with id")
	    unless $_ID_TO_TASK{$id};
    return $_ID_TO_TASK{$id};
}

=for html <a name="handle_die"></a>

=head2 handle_die(string die_msg)

Something happened while executing a request, so we have to rollback
and discard the mail queue.

=cut

sub handle_die {
    my($proto, $die_msg) = @_;
    # Only rollback if there was an action
    if (ref($proto) eq __PACKAGE__ && $proto->{$_PACKAGE}->{action_class}) {
	Bivio::SQL::Connection->rollback;
	Bivio::Mail::Common->discard_queued_messages;
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
