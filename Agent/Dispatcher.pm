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
appropriate Request subclass and then passes it off to the controller
which registered for that request.

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Agent::Dispatcher

Creates a new dispatcher.

=cut

sub new {
    my($self) = &Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {
	'controllers' => {},
    };
    return $self;
}
=head1 METHODS

=for html <a name="process_request"></a>

=head2 process_request(Bivio::Agent::Request req)

Looks up and invokes the controller for the specified request. If a
controller exists for the message, then the the controller's
handle_request() method is invoked. If multiple controllers have
registered using the same name, then each is invoked until one of
them handles the request.

=cut

sub process_request {
    my($self, $req) = @_;
    my($controllers) = $self->{$_PACKAGE}->{controllers};
    # make sure the request isn't already in error
    if ($req->get_state() != Bivio::Agent::Request::NOT_HANDLED ) {
	return;
    }
    my($list) = $controllers->{$req->get_controller_name()};

    # iterate the controller list until one of them handles the request
    if ($list) {
	my($controller);
	foreach $controller (@$list) {
	    $controller->handle_request($req);
	    return if $req->get_state() != Bivio::Agent::Request::NOT_HANDLED;
	}
    }
    return;
}

=for html <a name="register_controller"></a>

=head2 static register_controller(string name, Bivio::Agent::Controller controller)

Controller implementation registration. Multiple controllers can be
registered under the same name. Each controller will be invoked until
one of them handles the request.

=cut

sub register_controller {
    my($self, $name, $controller) = @_;
    my($controllers) = $self->{$_PACKAGE}->{controllers};
    UNIVERSAL::isa($controller, 'Bivio::Agent::Controller')
		|| die("not a controller");
    if (!$controllers->{$name}) {
	# create a list if it is a new name
	$controllers->{$name} = [$controller];
    }
    else {
	push(@{$controllers->{$name}}, $controller);
    }
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
