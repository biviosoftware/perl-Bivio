# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Views;
use strict;
$Bivio::Agent::Views::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::Views - initializes all views (deprecated)

=head1 SYNOPSIS

    use Bivio::Agent::Views;
    Bivio::Agent::Views->initialize;

=cut

use Bivio::UNIVERSAL;
@Bivio::Agent::Views::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Agent::Views>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::UI::HTML::Page;
use Bivio::UI::HTML::Presentation;
use Bivio::UI::Menu;
use Bivio::Collection::SingletonMap;
use Carp ();

#=VARIABLES
my($_INITIALIZED) = 0;
my(@_PERSISTENT);

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 static initialize()

Initialize all views, presentations, and pages.

=cut

sub initialize {
    return if $_INITIALIZED;
    $_INITIALIZED = 1;
    # Assemble pages and presentations from views.  Note that
    # the Views have backlinks to their parents, so they can never
    # be garbage collected--which is what we want.n
    my($setup) = Bivio::UI::HTML::Presentation->new([
	Bivio::Collection::SingletonMap->get(qw(
	    Bivio::UI::Setup::Intro
	    Bivio::UI::Setup::Admin
	    Bivio::UI::Setup::Login
	    Bivio::UI::Setup::Club
	    Bivio::UI::Setup::Finish
    ))]);
    push(@_PERSISTENT, $setup);
    push(@_PERSISTENT, Bivio::UI::HTML::Page->new([$setup],
 	    Bivio::UI::Menu->new(1,
		    [Bivio::Agent::TaskId::SETUP_INTRO, 'Club Setup'])));
    my($admin) = Bivio::UI::HTML::Presentation->new([
	Bivio::Collection::SingletonMap->get(qw(
	    Bivio::UI::Admin::UserListView
	    Bivio::UI::Admin::UserView
    ))]);
    push(@_PERSISTENT, $admin);
    my($messages) = Bivio::UI::HTML::Presentation->new([
	Bivio::Collection::SingletonMap->get(qw(
	    Bivio::UI::MessageBoard::ListView
	    Bivio::UI::MessageBoard::DetailView
    ))]);
    push(@_PERSISTENT, $messages);
#TODO: Turn into tasks
    my($main_menu) = Bivio::UI::Menu->new(1, [
	    Bivio::Agent::TaskId::CLUB_MEMBER_LIST, 'Administration',
	    Bivio::Agent::TaskId::CLUB_MESSAGE_LIST, 'Messages']);
    push(@_PERSISTENT, $main_menu);
    push(@_PERSISTENT, Bivio::UI::HTML::Page->new(
 	    [$admin, $messages], $main_menu));
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
