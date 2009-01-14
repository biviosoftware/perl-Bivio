# Copyright (c) 2000-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Job::Dispatcher;
use strict;
use Bivio::Base 'Agent.Dispatcher';

# C<Bivio::Agent::Job::Dispatcher> is used to queue tasks at the end
# of other dispatcher tasks.  There is only one queue.  It is cleared
# by L<Bivio::Agent::Task|Bivio::Agent::Task> on errors.  You may
# not queue new jobs during L<execute_queue|"execute_queue">.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = b_use('AgentJob.Request');
my($_TI) = b_use('Agent.TaskId');
# Don't allow queueing while in execute.
my($_SELF);
my($_IN_EXECUTE) = 0;
my(@_QUEUE);
__PACKAGE__->initialize;

sub create_request {
    # (self, hash_ref) : Agent.Request
    # Creates and returns a request.
    my($self, $params) = @_;
    return $_R->new($params);
}

sub discard_queue {
    # (self) : undef
    # Clears the queue.  May be called at any time.
    @_QUEUE = ();
    return;
}

sub enqueue {
    # (self, Agent.Request, any, hash_ref) : undef
    # Enqueue I<task> with I<params>.  The I<auth_id> and and auth_user_id are
    # extracted from I<req>, if they are not supplied in I<params>.  I<params> may
    # not contain any models.  All models must be freshly loaded for each job.
    #
    # May not be called during L<execute_queue|"execute_queue">.
    my($self, $req, $task_id, $params) = @_;
    Bivio::Die->die('not allowed to call enqueue in execute_queue')
	if $_IN_EXECUTE;

    # No models please
    while (my($k, $v) = each(%$params)) {
	Bivio::Die->die('models may not be queued: ', $k, '=', $v)
	    if UNIVERSAL::isa($v, 'Bivio::Biz::Model');
    }

    # Validate task
    $task_id = $_TI->from_any($task_id);

    # Extract params from request
    $params->{task_id} = $task_id;
    my($u) = $req->get('auth_user');
    $params->{auth_user_id} ||= $u ? $u->get('realm_id') : undef;
    foreach my $p (qw(auth_id Bivio::UI::Facade is_secure client_addr)) {
	$params->{$p} = $req->unsafe_get($p)
	    unless exists($params->{$p});
    }

    # Enqueue and add as a txn resource (may end up calling handle_rollback
    # multiple times, but the routine is re-enterable).
    $req->push_txn_resource($self);
    push(@_QUEUE, $params);
    return;
}

sub execute_queue {
    # (proto) : undef
    # Processes the queue.  Called from Mail or HTTP dispatcher after
    # request completes.
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

sub handle_commit {
    # (self) : undef
    # Commit called, do nothing.
    return;
}

sub handle_rollback {
    # (self) : undef
    # Rollback called, clear queue.
    my($self) = @_;
    $self->discard_queue;
    return;
}

sub initialize {
    # (proto) : undef
    # Called on first request.
    my($proto) = @_;
    return if $_SELF;
    $_SELF = $proto->new;
    $_SELF->SUPER::initialize();
    return;
}

sub queue_is_empty {
    # (self) : boolean
    # Returns true if the queue is empty.
    return @_QUEUE ? 0 : 1;
}

1;
