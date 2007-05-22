# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Dispatcher;
use strict;

$Bivio::Agent::Dispatcher::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Agent::Dispatcher::VERSION;

=head1 NAME

Bivio::Agent::Dispatcher - HTTP and email dispatcher

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Agent::Dispatcher;
    Bivio::Agent::Dispatcher->new();

=cut

@Bivio::Agent::Dispatcher::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Agent::Dispatcher> is the outside entry point into the Bivio
application. When the dispatcher receives input, it wraps it in the
appropriate Request subclass, checks the user is authorized to
execute a task, and excutes the Task.

=cut


=head1 CONSTANTS

=cut

=for html <a name="MAX_SERVER_REDIRECTS"></a>

=head2 MAX_SERVER_REDIRECTS : int

Maximum number of server redirects.

=cut

sub MAX_SERVER_REDIRECTS {
    return 4;
}

#=IMPORTS
use Bivio::Agent::Request;
use Bivio::Agent::Task;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Alert;
use Bivio::IO::Trace;
use Bivio::UI::Facade;

#=VARIABLES
my($_INITIALIZED);
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Agent::Dispatcher

Creates a new dispatcher.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="process_request"></a>

=head2 process_request(array protocol_args) : Bivio::Die

Creates a request and returns a result.  Resets the warn counter at
the end of each request.

Returns undef if no errors are encountered.

=cut

sub process_request {
    my($self, @protocol_args) = @_;
    Bivio::Agent::Request->clear_current;
    my($die, $req, $task_id);
    my($redirect_count) = -1;
 TRY: {
	$die = Bivio::Die->catch(sub {
	    die("too many dispatcher retries")
		if ++$redirect_count > $self->MAX_SERVER_REDIRECTS;
	    unless ($req) {
		$req = $self->create_request(@protocol_args);
		_trace('create_request: ', $req) if $_TRACE;
	    }
	    $task_id = $req->get('task_id') unless $task_id;
	    _trace('Executing: ', $task_id) if $_TRACE;
	    my($task) = Bivio::Agent::Task->get_by_id($task_id);
	    $req->put_durable(
		task => $task,
		redirect_count => $redirect_count,
	    );
#TODO: This coupling needs to be explicit.  Probably with a handler.
	    $req->delete(qw(list_model form_model));
	    # Task checks authorization
	    $task->execute($req);
	});

	# Is this redirect?  If we have exceeded redirect count, we may blow up
	# with a DIE (see above).  It is better to check again here, because
	# there may be a bug in the error redirect mapping.
	if ($die
	    && $die->get('code') == Bivio::DieCode->SERVER_REDIRECT_TASK
	    && $redirect_count <= $self->MAX_SERVER_REDIRECTS
	) {
	    #NOTE: Coupling with Request::internal_server_redirect.
	    #      It already has set all the state
	    my($attrs) = $die->get('attrs');
	    _trace('redirect from ', $task_id, ' to ', $attrs->{task_id})
		if $_TRACE;
#TODO: add this when thoroughly debugged
#	    $req->clear_nondurable_state;
            $task_id = $attrs->{task_id};
#TODO: Can we remove the line below?
	    $req->internal_redirect_realm($task_id);
	    redo TRY;
	}
    }

    $req->process_cleanup($die)
        if $req;
    Bivio::Agent::Request->clear_current;
    Bivio::IO::Alert->reset_warn_counter;
    return $die;
}

=for html <a name="initialize"></a>

=head2 static initialize(boolean partially)

Initialize Agent state.

I<partially> passes through to L<Bivio::Agent::Task|Bivio::Agent::Task>
and L<Bivio::UI::Facade|Bivio::UI::Facade>.

B<Only initialize partially in non-server environments.>

=cut

sub initialize {
    my($proto, $partially) = @_;
    return if $_INITIALIZED;
    # Only one try at this
    $_INITIALIZED = 1;

    # Ensure we don't do something stupid.
    Bivio::Die->die('partial init not allowed in mod_perl')
		if $partially && exists($ENV{MOD_PERL});

    # Need a current request for initialization
    Bivio::Agent::Request->get_current_or_new;
    Bivio::Agent::Task->initialize($partially);
    Bivio::UI::Facade->initialize($partially);

    _trace("Size of process before fork\n", `ps v $$`) if $_TRACE;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
