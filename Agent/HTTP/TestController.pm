# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::TestController;
use strict;

$Bivio::Agent::HTTP::TestController::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::HTTP::TestController - a test controller.

=head1 EXTENDS

L<Bivio::Agent::Controller>

=cut

use Bivio::Agent::Controller;
@Bivio::Agent::HTTP::TestController::ISA = qw(Bivio::Agent::Controller);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::TestController> is a testing controller which just
dumps the contents of the request to the html page.

=cut

#=IMPORTS
use Bivio::Agent::Request;
use Data::Dumper ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_PAGE) = 0;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Agent::HTTP::TestController

Creates a new TestController.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Agent::Controller::new($proto, []);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="handle_request"></a>

=head2 handle_request(Request req)

Prints out the request information to a simple page.

=cut

sub handle_request {
    my($self, $req) = @_;

    if (! $req->get_user()) {
	$req->set_state(Bivio::Agent::Request::AUTH_REQUIRED);
	return;
    }

    $req->print("<html><body>");
    $req->print("target = ".$req->get_target_name()."<br>");
    $req->print("controller = ".$req->get_controller_name()."<br>");
    $req->print("view = ".$req->get_view_name()."<br>");
    $req->print("action = ".$req->get_action_name()."<br>");
    $Data::Dumper::Indent = 1;
    $req->print("<pre>finder =".Data::Dumper->Dumper($req->get_model_args())
	    ."</pre>\n");
    $req->print("<pre>user = ".Data::Dumper->Dumper($req->get_user())
	    ."<pre><br>&nbsp<br>");
    $req->print("</body></html>");
    $req->set_state(Bivio::Agent::Request::OK);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
