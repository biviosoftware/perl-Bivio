# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Dispatcher;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::IO::Trace;

# C<Bivio::Agent::Dispatcher> is the outside entry point into the Bivio
# application. When the dispatcher receives input, it wraps it in the
# appropriate Request subclass, checks the user is authorized to
# execute a task, and excutes the Task.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_INITIALIZED);
use vars qw($_TRACE);
my($_F) = b_use('UI.Facade');
my($_T) = b_use('Agent.Task');
my($_R) = b_use('Agent.Request');
my($_A) = b_use('IO.Alert');
my($_D) = b_use('Bivio.Die');
my($_DC) = b_use('Bivio.DieCode');

sub MAX_SERVER_REDIRECTS {
    return 4;
}

sub initialize {
    my($proto, $partially) = @_;
    return
	if $_INITIALIZED;
    $_INITIALIZED = 1;
    # Ensure we don't do something stupid.
    b_die('partial init not allowed in mod_perl')
	if $partially && exists($ENV{MOD_PERL});
    $_R->get_current_or_new;
    $_T->initialize($partially);
    $_F->initialize($partially);
    _trace("Size of process before fork\n", `ps v $$`) if $_TRACE;
    return;
}

sub internal_server_redirect_task {
    my($self, $curr_task, $die, $req) = @_;
    #NOTE: Coupling with Request::internal_server_redirect.
    #      It already has set all the state
    my($attrs) = $die->get('attrs');
    _trace('redirect from ', $curr_task, ' to ', $attrs->{task_id})
	if $_TRACE;
#TODO: add this when thoroughly debugged
#	    $req->clear_nondurable_state;
    if ($curr_task == $attrs->{task_id} && $curr_task->get_name =~ /ERROR/) {
	b_warn($curr_task, ': not redirecting to identical ERROR task');
	return;
    }
    return $attrs->{task_id};
}

sub process_request {
    my($self, @protocol_args) = @_;
    $_R->clear_current;
    my($die, $req, $task_id);
    my($redirect_count) = -1;
 TRY: {
	$die = $_D->catch(sub {
	    die("too many dispatcher retries")
		if ++$redirect_count > $self->MAX_SERVER_REDIRECTS;
	    unless ($req) {
		$req = $self->create_request(@protocol_args);
		_trace('create_request: ', $req) if $_TRACE;
	    }
	    $task_id = $req->get('task_id')
		unless $task_id;
	    _trace('Executing: ', $task_id) if $_TRACE;
	    my($task) = $_T->get_by_id($task_id);
	    $req->put_durable(
		task => $task,
		redirect_count => $redirect_count,
	    );
#TODO: This coupling needs to be explicit.  Probably with a handler.
	    $req->delete(qw(list_model form_model));
	    $task->execute($req);
	});
	if ($die
	    && $die->get('code') == $_DC->SERVER_REDIRECT_TASK
	    && $redirect_count <= $self->MAX_SERVER_REDIRECTS
	) {
	    last TRY
		unless $task_id
		= $self->internal_server_redirect_task($task_id, $die, $req);
#TODO: Can we remove the line below?
	    $req->internal_redirect_realm($task_id);
	    redo TRY;
	}
    }
    $req->process_cleanup($die)
        if $req;
    $_R->clear_current;
    $_A->reset_warn_counter;
    return $die;
}

1;
