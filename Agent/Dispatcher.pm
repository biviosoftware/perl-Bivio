# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Dispatcher;
use strict;
use Apache::Constants();
use Bivio::Agent::Request();
use Bivio::Agent::HTTP::Request();
$Bivio::Agent::Dispatcher::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::Dispatcher - HTTP and email dispatcher

=head1 SYNOPSIS

    use Bivio::Agent::Dispatcher;
    Bivio::Agent::Dispatcher->new();

=cut

@Bivio::Agent::Dispatcher::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Agent::Dispatcher> is the outside entry point into the Bivio
application. When the dispatcher receives input, it wraps it in the
appropriate Request subclass, checks the user is authorized to
execute a task, and excutes the Task.

=cut

#=IMPORTS
use Bivio::Agent::HTTP::Location;
use Bivio::Agent::Tasks;
use Bivio::Agent::Views;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_INITIALIZED);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Agent::Dispatcher

Creates a new dispatcher.

=cut

sub new {
    my($self) = &Bivio::UNIVERSAL::new(@_);
    return $self;
}
=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 static initialize()

Initialize Agent state.

=cut

sub initialize {
    $_INITIALIZED && return;
    Bivio::Agent::HTTP::Location->initialize;
    Bivio::Agent::Views->initialize;
    Bivio::Agent::Tasks->initialize;
    $_INITIALIZED = 1;
    return;
}

=for html <a name="process_requets"></a>

=head2 process_request(Bivio::Agent::Request req)

Checks task authorization and executes.

=cut

sub process_request {
    my($self, $req) = @_;
    my($auth_realm, $auth_user, $task_id)
	    = $req->get(qw(auth_realm auth_user task_id));
    my($owner) = $auth_realm->unsafe_get('owner');
    if ($owner) {
	my($f) = $auth_realm->get('owner_id_field');
	$req->put(auth_owner_id => $owner->get($f),
		auth_owner_id_field => $f);
    }
    my($auth_role) = $auth_realm->get_user_role($auth_user, $req);
    my($reply) = $req->get('reply');
    unless ($auth_realm->can_role_execute_task($auth_role, $task_id)) {
	&_trace($auth_user, ": auth denied for ", $task_id, " as ",
		$auth_role) if $_TRACE;
	$reply->set_state($auth_user ? $reply->FORBIDDEN
		: $reply->AUTH_REQUIRED);
	return;
    }
    my($task) = Bivio::Agent::Task->get_by_id($task_id);
    $req->put(task => $task,
	    auth_role => $auth_role,
	    $owner ? (ref($owner) => $owner) : (),
	   );
    $task->execute($req);
#TODO: Remove this?
    $reply->set_state($reply->OK);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut


# for testing
#use Bivio::Agent::HTTP::TestController();
#Bivio::Agent::HTTP::TestController->create_test_site();

# site initialization - should be from config file

1;
