# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Job::Dispatcher;
use strict;
$Bivio::Agent::Job::Dispatcher::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::Job::Dispatcher - run tasks

=head1 SYNOPSIS

    use Bivio::Agent::Job::Dispatcher;
    Bivio::Agent::Job::Dispatcher->enqueue($task, $attrs);
    Bivio::Agent::Job::Dispatcher->execute_queue;
    Bivio::Agent::Job::Dispatcher->queue_is_empty;

=cut

=head1 EXTENDS

L<Bivio::Agent::Dispatcher>

=cut

use Bivio::Agent::Dispatcher;
@Bivio::Agent::Job::Dispatcher::ISA = ('Bivio::Agent::Dispatcher');

=head1 DESCRIPTION

C<Bivio::Agent::Job::Dispatcher> is used to queue tasks at the end
of other dispatcher tasks.  There is only one queue.  It is cleared
by L<Bivio::Agent::Task|Bivio::Agent::Task> on errors.  You may
not queue new jobs during L<execute_queue|"execute_queue">.

=cut

#=IMPORTS
use Bivio::Agent::Job::Request;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
# Don't allow queueing while in execute.
my($_SELF);
my($_INITIALIZED);
my($_IN_EXECUTE) = 0;
my(@_QUEUE);
__PACKAGE__->initialize;

=head1 METHODS

=cut

=for html <a name="create_request"></a>

=head2 create_request(hash_ref params) : Bivio::Agent::Request

Creates and returns a request.

=cut

sub create_request {
    my($self, $params) = @_;
    return Bivio::Agent::Job::Request->new($params);
}

=for html <a name="discard_queue"></a>

=head2 discard_queue()

Clears the queue.  May be called at any time.

=cut

sub discard_queue {
    @_QUEUE = ();
    return;
}

=for html <a name="enqueue"></a>

=head2 enqueue(Bivio::Agent::Request req, any task_id, hash_ref params)

Enqueue I<task> with I<params>.  The I<auth_id> and such are extracted
from I<req>.  I<params> may not contain any models.  All models must
be freshly loaded for each job.

May not be called during L<execute_queue|"execute_queue">.

=cut

sub enqueue {
    my($self, $req, $task_id, $params) = @_;
    Bivio::IO::Alert->die('not allowed to call enqueue in execute_queue')
		if $_IN_EXECUTE;

    # No models please
    while (my($k, $v) = each(%$params)) {
	Bivio::IO::Alert->die('models may not be queued: ', $k, '=', $v)
		    if UNIVERSAL::isa($v, 'Bivio::Biz::Model');
    }

    # Validate task
    $task_id = Bivio::Agent::TaskId->from_any($task_id);

    # Extract params from request
    $params->{task_id} = $task_id;
    $params->{auth_id} = $req->get('auth_id');
    my($u) = $req->get('auth_user');
    $params->{auth_user_id} = $u ? $u->get('realm_id') : undef;

    # Enqueue and add as a txn resource (may end up calling handle_rollback
    # multiple times, but the routine is re-enterable).
    $req->push_txn_resource($self);
    push(@_QUEUE, $params);
    return;
}

=for html <a name="execute_queue"></a>

=head2 static execute_queue()

Processes the queue.  Called from Mail or HTTP dispatcher after
request completes.

This is an L<Bivio::IPC::Server|Bivio::IPC::Server> upcall.

=cut

sub execute_queue {
    die('recursive call to execute_queue') if $_IN_EXECUTE;
    $_IN_EXECUTE = 1;

    # Iterate through each item in the queue
    while (@_QUEUE) {
	my($params) = shift(@_QUEUE);
	Bivio::IO::Alert->warn($$, ' JOB_START: ', $params);
	my($die) = $_SELF->process_request({%{$params}});
	if ($die) {
	    Bivio::IO::Alert->warn($$, ' JOB_ERROR: ', $params, ' ', $die);
	}
	else {
	    Bivio::IO::Alert->warn($$, ' JOB_END: ', $params);
	}
    }
    $_IN_EXECUTE = 0;
    return;
}

=for html <a name="handle_commit"></a>

=head2 handle_commit()

Commit called, do nothing.

=cut

sub handle_commit {
    return;
}

=for html <a name="handle_rollback"></a>

=head2 handle_rollback()

Rollback called, clear queue.

=cut

sub handle_rollback {
    my($self) = @_;
    $self->discard_queue;
    return;
}

=for html <a name="initialize"></a>

=head2 static initialize()

Called on first request.

=cut

sub initialize {
    my($proto) = @_;
    $_INITIALIZED && return;
    $_SELF = $proto->new;
    $_SELF->SUPER::initialize();
    $_INITIALIZED = 1;
    return;
}

=for html <a name="queue_is_empty"></a>

=head2 queue_is_empty() : boolean

Returns true if the queue is empty.

=cut

sub queue_is_empty {
    return @_QUEUE ? 0 : 1;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
