# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::TestController;
use strict;
use Bivio::Agent::Controller();
#use Bivio::Agent::Dispatcher();
use Bivio::Agent::Request();
use Bivio::UI::Menu();
use Bivio::UI::TestView();
use Bivio::UI::HTML::Presentation();
use Bivio::UI::HTML::Page();
use Bivio::BusObj::TestModel();

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
my($_PAGE) = 0;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(array views, View default_view) : Bivio::Agent::HTTP::TestController

Creates a new TestController.

=cut

sub new {
    my($proto, $views, $default_view) = @_;
    my($self) = &Bivio::Agent::Controller::new($proto, $views, $default_view);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="create_test_site"></a>

=head2 static create_test_site()

Creates a test animal site.

=cut

sub create_test_site {

    &_create_page();
}

=for html <a name="handle_request"></a>

=head2 handle_request(Request req)

Exercises a simple page.

=cut

sub handle_request {
    my($self, $req) = @_;

    if ($_PAGE == 0) {
	die("page not created");
    }
    my($view) = $self->get_view($req->get_view_name());

    if (defined($view)) {

	my($model) = Bivio::BusObj::TestModel->new({}, "T", "t");
	$view->activate()->render($model, $req);
	$req->set_state(Bivio::Agent::Request::OK);
    }
    else {
	$req->set_state(Bivio::Agent::Request::NOT_HANDLED);
    }
}

#=PRIVATE METHODS

# Prints request info.
#
sub _test {
    my($req) = @_;

    #$req->log_error("\n\ngot request!!!\n\n\n");

    if (! $req->get_user_name()) {
	$req->set_state(Bivio::Agent::Request::AUTH_REQUIRED);
	return;
    }

    $req->print("<html><body>");
    $req->print("target = ".$req->get_target_name()."<br>");
    $req->print("controller = ".$req->get_controller_name()."<br>");
    $req->print("view = ".$req->get_view_name()."<br>");
    $req->print("user = ".$req->get_user_name()."<br>");
    $req->print("<p>\n");

    $req->print("</body></html>");
    $req->set_state(Bivio::Agent::Request::OK);
}

# Creates the animal friendly page.
#
sub _create_page {
    my($paul_view) = Bivio::UI::TestView->new("paul",
	'<img src="/i/test/paul.jpg">');

    my($ellen_view) = Bivio::UI::TestView->new("ellen",
	'<img src="/i/test/ellen.jpg">');

    my($electra_view) = Bivio::UI::TestView->new("electra",
	'<img src="/i/test/electra.jpg">');

    my($orestes_view) = Bivio::UI::TestView->new("orestes",
	'<img src="/i/test/orestes.jpg">');

    my($ole_view) = Bivio::UI::TestView->new("ole",
	'<img src="/i/test/ole.jpg">');

    my($human_menu) = Bivio::UI::Menu->new(0,
	    [$paul_view->get_name(), "Paul Moeller",
	     $ellen_view->get_name(), "Ellen Moeller"]);
    my($human) = Bivio::UI::HTML::Presentation->new(
	    [$paul_view, $ellen_view], $human_menu);

    my($cat_menu) = Bivio::UI::Menu->new(0,
	    [$electra_view->get_name(), "Electra",
	     $orestes_view->get_name(), "Orestes"]);
    my($cat) = Bivio::UI::HTML::Presentation->new(
	    [$electra_view, $orestes_view], $cat_menu);

    my($dog) = Bivio::UI::HTML::Presentation->new(
	    [$ole_view]);

    my($main_menu) = Bivio::UI::Menu->new(1,
	    ['human', 'Human',
	     'cat', 'Cat',
	     'dog', 'Dog']);

    my($page) = Bivio::UI::HTML::Page->new(
	    [$human, $cat, $dog], $main_menu);

    $_PAGE = $page;

    my($human_controller) = Bivio::Agent::HTTP::TestController->new(
	    [$paul_view, $ellen_view], $ellen_view);
    Bivio::Agent::Dispatcher::register_controller('human', $human_controller);

    my($dog_controller) = Bivio::Agent::HTTP::TestController->new(
	    [$ole_view], $ole_view);
    Bivio::Agent::Dispatcher::register_controller('dog', $dog_controller);

    my($cat_controller) = Bivio::Agent::HTTP::TestController->new(
	    [$electra_view, $orestes_view], $electra_view);
    Bivio::Agent::Dispatcher::register_controller('cat', $cat_controller);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
