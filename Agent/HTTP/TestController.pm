# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::TestController;
use strict;
use Bivio::Agent::Controller();
use Bivio::Agent::Request();
$Bivio::Agent::HTTP::TestController::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Agent::HTTP::TestController - a test controller.

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::TestController;
    Bivio::Agent::HTTP::TestController->new();

=cut

=head1 EXTENDS

L<Bivio::Agent::Controller>

=cut

@Bivio::Agent::HTTP::TestController::ISA = qw(Bivio::Agent::Controller);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::TestController>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES

#cached pages for _test3()
my($PAGE) = 0;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Agent::HTTP::TestController

Creates a new TestController.

=cut

sub new {
    my($self) = &Bivio::Agent::Controller::new(@_);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="handle_request"></a>

=head2 handle_request(Request req)

Exercises a simple page.

=cut

sub handle_request {
    my($self,$req) = @_;

    &_test3($req);
}

#=PRIVATE METHODS

# Prints request info.
#
sub _test {
    my($req) = @_;

    #$req->log_error("\n\ngot request!!!\n\n\n");

    if (! $req->get_user()) {
	$req->set_state(Bivio::Agent::Request::AUTH_REQUIRED);
	return;
    }

    $req->print("<html><body>");
    $req->print("target = ".$req->get_target_name()."<br>");
    $req->print("controller = ".$req->get_controller_name()."<br>");
    $req->print("path = ".join('/', @{$req->get_path()})."<br>");
    $req->print("user = ".$req->get_user()."<br>");
    $req->print("<p>\n");

    $req->print("</body></html>");
    $req->set_state(Bivio::Agent::Request::OK);
}

use Bivio::UI::HTML::TestView;
use Bivio::UI::HTML::Presentation;
use Bivio::UI::HTML::Page;

# Creates a test page and renders it.
#
sub _test2 {
    my($req) = @_;
    my($test_view) = Bivio::UI::HTML::TestView->new("Test Title",
	"<i>a test view</i>");

    my($test_view2) = Bivio::UI::HTML::TestView->new("Test Title 2",
	"<b>another test view</b>");

    my($test_view3) = Bivio::UI::HTML::TestView->new("Test Title 3",
	"<small>a little view</small>");

    my($pres) = Bivio::UI::HTML::Presentation->new(
	["test", $test_view,
        "test2", $test_view2], "test2");

    my($pres2) = Bivio::UI::HTML::Presentation->new(
	["test3", $test_view3], "test3");

    my($page) = Bivio::UI::HTML::Page->new(
	["testcontroller", $pres,
	"testcontroller2", $pres2], "testcontroller");

    $page->set_path($req->get_path(), 1);

    $page->render(undef, undef);
    $req->set_state(Bivio::Agent::Request::OK);
}

# Creates an animal page and renders it.
#
sub _test3 {
    my($req) = @_;

    if ($PAGE == 0) {
	print( STDERR "\n\ncreating animal page\n\n");
	&_create_page();
    }
    $PAGE->set_path($req->get_path(), 1);
    $PAGE->render(undef, $req);
    $req->set_state(Bivio::Agent::Request::OK);
}

# Creates the animal friendly page.
#
sub _create_page {
    my($paul_view) = Bivio::UI::HTML::TestView->new("Paul Moeller",
	'<img src="/i/test/paul.jpg">');

    my($ellen_view) = Bivio::UI::HTML::TestView->new("Ellen Moeller",
	'<img src="/i/test/ellen.jpg">');

    my($electra_view) = Bivio::UI::HTML::TestView->new("Electra the cat",
	'<img src="/i/test/electra.jpg">');

    my($orestes_view) = Bivio::UI::HTML::TestView->new("Orestes the cat",
	'<img src="/i/test/orestes.jpg">');

    my($ole_view) = Bivio::UI::HTML::TestView->new("Ole the dog",
	'<img src="/i/test/ole.jpg">');

    my($human) = Bivio::UI::HTML::Presentation->new(
	["Paul", $paul_view,
	 "Ellen", $ellen_view], "Ellen");

    my($cat) = Bivio::UI::HTML::Presentation->new(
	["Electra", $electra_view,
	 "Orestes", $orestes_view], "Electra");

    my($dog) = Bivio::UI::HTML::Presentation->new(
	["Ole", $ole_view], "Ole");

    my($everybody) = Bivio::UI::HTML::Presentation->new(
	["Paul", $paul_view,
	 "Ellen", $ellen_view,
	 "Electra", $electra_view,
	 "Orestes", $orestes_view,
	 "Ole", $ole_view], "Paul");

    my($page) = Bivio::UI::HTML::Page->new(
	["Human", $human,
	 "Cat", $cat,
	 "Dog", $dog,
	 "Everybody", $everybody], "Cat");

    $PAGE = $page;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
