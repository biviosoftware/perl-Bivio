# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Dispatcher;
use strict;
use Apache::Constants();
use Bivio::Agent::Request();
use Bivio::Agent::HTTP::Request();
$Bivio::Agent::Dispatcher::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

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

=head1 CONSTANTS

=cut

sub _DEFAULT_HTTP_CONTROLLER_NAME {
    return 'admin';
}

#=VARIABLES

# The controller implementations array lookup, keyed by name.
#
my(%_CONTROLLERS);

=head1 METHODS

=cut

=for html <a name="handler"></a>

=head2 static handler(Apache::Request r) : int

Handler called by mod_perl, creates a HTTP::Request which wraps
Apache::Request. Then it invokes the appropriate Controller to handle
the request.

=cut

sub handler {
    my($r) = @_;

    my($request) = Bivio::Agent::HTTP::Request->new($r,
	   _DEFAULT_HTTP_CONTROLLER_NAME());

    _process_request($request);
#    eval '_process_request($request);' || die($@);

    return $request->get_http_return_code();
}

=for html <a name="mhonarc_addhook"></a>

=head2 static mhonarc_addhook(int index, string filename) : int

Called by mhamain.pl:output_mail (MHonArc/lib) after the message has been
written in html format.

=cut

sub mhonarc_addhook {
    my($index, $filename) = @_;

    die("not implemented yet");

    #my($request) = MailRequest->new($index, $filename);
    #_process_requesut($request);
    #return $request->get_mail_return_code();
}

=for html <a name="register_controller"></a>

=head2 static register_controller(String name, Controller controller)

Controller implementation registration. Multiple controllers can be
registered under the same name. Each controller will be invoked until
one of them handles the request.

=cut

sub register_controller {
    my($name, $controller) = @_;

    if (! $_CONTROLLERS{$name}) {

	# create a list if it is a new name
	$_CONTROLLERS{$name} = [];
    }
    my($list) = $_CONTROLLERS{$name};
    push(@$list, $controller);
}

# _process_request(Request req)
#
# Looks up and invokes the controller for the specified request. If a
# controller exists for the message, then the the controller's
# handle_request() method is invoked. If multiple controllers have
# registered using the same name, then each is invoked until one of
# them handles the request.
#
sub _process_request {
    my($req) = @_;

    # make sure the request isn't already in error
    if ($req->get_state() != Bivio::Agent::Request::NOT_HANDLED ) {
	return;
    }

    my($list) = $_CONTROLLERS{$req->get_controller_name()};

    # iterate the controller list until one of them handles the request
    if ($list) {
	my($controller);
	foreach $controller (@$list) {
	    $controller->handle_request($req);
	    return if $req->get_state() != Bivio::Agent::Request::NOT_HANDLED;
	}
    }
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut


# for testing
#use Bivio::Agent::HTTP::TestController();
#Bivio::Agent::HTTP::TestController->create_test_site();

# site initialization - should be from config file

use Bivio::Agent::HTTP::SiteStart;
Bivio::Agent::HTTP::SiteStart->init();

1;
