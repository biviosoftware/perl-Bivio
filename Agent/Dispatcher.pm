# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Dispatcher;
use strict;

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
use BSD::Resource;
use Bivio::Agent::HTTP::Location;
use Bivio::Agent::HTTP::Request;
use Bivio::Agent::Tasks;
use Bivio::Agent::Views;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Trace;

#=VARIABLES
# No cor dumps please
setrlimit(RLIMIT_CORE, 0, 0);

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

=for html <a name="process_request"></a>

=head2 process_request(array protocol_args) : undef or Bivio::Die

Creates a request and returns a result.

=cut

sub process_request {
    my($self, @protocol_args) = @_;
    Bivio::Agent::Request->clear_current;
    my($die) = Bivio::Die->catch(sub {
	my($req) = $self->create_request(@protocol_args);
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
	    Bivio::Die->die($auth_user ? 'FORBIDDEN' : 'AUTH_REQUIRED',
		    {auth_user => $auth_user, entity => $auth_realm,
			auth_role => $auth_role, operation => $task_id});
	}
	my($task) = Bivio::Agent::Task->get_by_id($task_id);
	$req->put(task => $task, auth_role => $auth_role,
		$owner ? (ref($owner) => $owner) : ());
	$task->execute($req);
	$reply->flush;
    });
    Bivio::Agent::Request->clear_current;
    return $die;
}

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
