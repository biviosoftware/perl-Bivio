# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::SiteStart;
use strict;
$Bivio::Agent::HTTP::SiteStart::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Agent::HTTP::SiteStart - web site initialization

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::SiteStart;
    Bivio::Agent::HTTP::SiteStart->new();

=cut

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::SiteStart>

=cut

#=IMPORTS
#use Bivio::Agent::Dispatcher;
use Bivio::Agent::HTTP::AdminController;
use Bivio::Agent::HTTP::ClubSetupController;
use Bivio::Agent::HTTP::MessageController;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::UI::Admin::UserListView;
use Bivio::UI::Admin::UserView;
use Bivio::UI::HTML::Page;
use Bivio::UI::HTML::Presentation;
use Bivio::UI::Menu;
use Bivio::UI::Setup::Admin;
use Bivio::UI::Setup::Club;
use Bivio::UI::Setup::Finish;
use Bivio::UI::Setup::Intro;
use Bivio::UI::TestView;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_INITIALIZED) = 0;

=head1 METHODS

=cut

=for html <a name="init"></a>

=head2 static init()

Creates and initializes all the views and controllers.

=cut

sub init {
    return if $_INITIALIZED;

    $_INITIALIZED = 1;

    Bivio::IO::Config->initialize({
	'Bivio::Ext::DBI' => {
	    ORACLE_HOME => '/usr/local/oracle/product/8.0.5',
	    database => 'surf_test',
	    user => 'moeller',
	    password => 'bivio,ho'
        },

	'Bivio::IO::Trace' => {
	    'package_filter' => '/Bivio/'
        },
    });

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
    my($message_list) = Bivio::UI::TestView->new("messages",
	    "<i>Message List</i>", $default_model);
    my($message_detail) = Bivio::UI::TestView->new("message", "<i>Message</i>",
	    $default_model);

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
    Bivio::Agent::Dispatcher::register_controller('setup',
	    $club_setup_controller);

    my($admin_controller) = Bivio::Agent::HTTP::AdminController->new(
	    [$user_list, $add_user], $user_list);
    Bivio::Agent::Dispatcher::register_controller('admin', $admin_controller);

    my($message_controller) = Bivio::Agent::HTTP::MessageController->new(
	    [$message_list, $message_detail], $message_list);
    Bivio::Agent::Dispatcher::register_controller('messages',
	    $message_controller);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
