# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Dispatcher;
use strict;
$Bivio::Agent::HTTP::Dispatcher::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Agent::HTTP::Dispatcher - dispatches Apache httpd requests

=head1 SYNOPSIS

    PerlModule Bivio::Agent::HTTP::Dispatcher
    <LocationMatch "^/\w{3,}($|/)">
    AuthName bivio
    AuthType Basic
    SetHandler perl-script
    PerlHandler Bivio::Agent::HTTP::Dispatcher
    </LocationMatch>

=cut

=head1 EXTENDS

L<Bivio::Agent::Dispatcher>

=cut

use Bivio::Agent::Dispatcher;
@Bivio::Agent::HTTP::Dispatcher::ISA = qw(Bivio::Agent::Dispatcher);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Dispatcher> is an L<Apache> L<mod_perl|mod_perl>
handler.  It creates a single instance of itself on the first request.

=cut

=head1 CONSTANTS

=cut

sub _DEFAULT_CONTROLLER_NAME {
    return 'messages';
}

#=IMPORTS
use Bivio::Agent::Dispatcher;
use Bivio::Agent::HTTP::AdminController;
use Bivio::Agent::HTTP::ClubSetupController;
use Bivio::Agent::HTTP::MessageController;
use Bivio::IO::Trace;
use Bivio::UI::Admin::UserListView;
use Bivio::UI::Admin::UserView;
use Bivio::UI::HTML::Page;
use Bivio::UI::HTML::Presentation;
use Bivio::UI::Menu;
use Bivio::UI::MessageBoard::DetailView;
use Bivio::UI::MessageBoard::MessageListView;
use Bivio::UI::Setup::Admin;
use Bivio::UI::Setup::Club;
use Bivio::UI::Setup::Finish;
use Bivio::UI::Setup::Intro;
use Bivio::UI::TestView;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_SELF);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Agent::HTTP::Dispatcher

Creates a new dispatcher.

=cut

sub new {
    my($self) = &Bivio::Agent::Dispatcher::new(@_);
    $self->_initialize();
    return $self;
}

=head1 METHODS

=cut

=for html <a name="handler"></a>

=head2 static handler(Apache::Request r) : int

Handler called by L<mod_perl|mod_perl>, creates a
L<Bivio::Agent::HTTP::Request|Bivio::Agent::HTTP::Request>
which wraps
L<Apache::Request|Apache::Request>.
Then it invokes the appropriate
L<Bivio::Agent::Controller|Bivio::Agent::Controller> 
to handle the request.

Returns an HTTP code defined in L<Apache::Constants|Apache::Constants>.

=cut

sub handler {
    my($r) = @_;
    my($return_code);
    eval {
	defined($_SELF) || ($_SELF = $_PACKAGE->new());
	my($request) = Bivio::Agent::HTTP::Request->new($r,
		_DEFAULT_CONTROLLER_NAME());
	$_SELF->process_request($request);
	$return_code = $request->get_http_return_code();
	1;
    };
    unless (defined($return_code)) {
	warn($@);
	$return_code = Apache::Constants::SERVER_ERROR;
    }
    return $return_code;
}

#=PRIVATE METHODS

sub _initialize {
    my($self) = @_;
    defined($_SELF) || Bivio::IO::Config->initialize();
    my($default_model) = Bivio::Biz::TestModel->new("test", {}, "T", "t");

    my($setup_intro) = Bivio::UI::Setup::Intro->new();
    my($admin_setup) = Bivio::UI::Setup::Admin->new();
    my($club_setup) = Bivio::UI::Setup::Club->new();
    my($setup_finish) = Bivio::UI::Setup::Finish->new();

    my($setup_pres) = Bivio::UI::HTML::Presentation->new(
	    [$setup_intro, $admin_setup, $club_setup, $setup_finish]);
    my($setup_page) = Bivio::UI::HTML::Page->new([$setup_pres],
	    Bivio::UI::Menu->new(1, ['setup', 'Club Setup']));

    my($user_list) = Bivio::UI::Admin::UserListView->new();
    my($add_user) = Bivio::UI::Admin::UserView->new();
    my($message_list) = Bivio::UI::MessageBoard::MessageListView->new();
    my($message_detail) = Bivio::UI::MessageBoard::DetailView->new();

    my($admin) = Bivio::UI::HTML::Presentation->new([$user_list, $add_user]);
    my($messages) = Bivio::UI::HTML::Presentation->new([$message_list,
	    $message_detail]);

    my($main_menu) = Bivio::UI::Menu->new(1,
	    ['admin', 'Administration',
		    'messages', 'Messages']);

    my($page) = Bivio::UI::HTML::Page->new(
	    [$admin, $messages], $main_menu);

    my($club_setup_controller) = Bivio::Agent::HTTP::ClubSetupController->new(
	    [$setup_intro, $admin_setup, $club_setup, $setup_finish],
	    $setup_intro);
    $self->register_controller('setup', $club_setup_controller);

    my($admin_controller) = Bivio::Agent::HTTP::AdminController->new(
	    [$user_list, $add_user], $user_list);
    $self->register_controller('admin', $admin_controller);

    my($message_controller) = Bivio::Agent::HTTP::MessageController->new(
	    [$message_list, $message_detail], $message_list);
    $self->register_controller('messages', $message_controller);
    return;
}

=head1 SEE ALSO

Apache::Request, mod_perl, Bivio::Agent::HTTP::Request,
Bivio::Agent::Controller

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
