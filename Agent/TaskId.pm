# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::TaskId;
use strict;
$Bivio::Agent::TaskId::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::TaskId - enum of identifying all Societas tasks

=head1 SYNOPSIS

    use Bivio::Agent::TaskId;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Agent::TaskId::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Agent::TaskId> defines all possible "tasks" within the Societas.  A
structure of a task is defined in L<Bivio::Agent::TaskBivio::Agent::Task>.

C<TaskId>s are defined "OBJECT_VERB", so they sort nicely.  The list of
tasks defined in this module is:

=over 4

=item CLUB_MESSAGE_DETAIL

=item CLUB_MESSAGE_LIST

=item CLUB_MEMBER_ADD

=item CLUB_MEMBER_ADD_EDIT

=item CLUB_MEMBER_LIST

=item SETUP_USER_CREATE

=item SETUP_USER_EDIT
=
item SETUP_CLUB_CREATE

=item SETUP_INTRO

=item CLUB_MAIL_FORWARD

=item USER_MAIL_FORWARD

=back

=cut

#=IMPORTS

#=VARIABLES
my(@_CFG) = (
    # Always start enums at 1, so 0 can be reserved for UNKNOWN.
    # DO NOT CHANGE the order of this list, the values may be
    # stored in the database.
    # undefs are fixed up with magic map below.
    [qw(
        CLUB_MESSAGE_DETAIL
        1
        CLUB
        MEMBER
        _/messages/detail
	undef
	MessageBoard::DetailView
    )],
    [qw(
        CLUB_MESSAGE_LIST
        2
        CLUB
        MEMBER
        _:_/messages
	undef
	MessageBoard::ListView
    )],
    [qw(
	CLUB_MEMBER_ADD
	3
        CLUB
        ADMINISTRATOR
        _/members/added
	AddClubUser
	Admin::UserListView
    )],
    [qw(
	CLUB_MEMBER_ADD_EDIT
	4
        CLUB
        ADMINISTRATOR
        _/members/new
	undef
	Admin::UserView
    )],
    [qw(
	CLUB_MEMBER_LIST
	5
        CLUB
        MEMBER
        _/members
	undef
	Admin::UserListView
    )],
    [qw(
	SETUP_USER_CREATE
	6
	PUBLIC
	ANONYMOUS
	user/created
	CreateUser
	Setup::Login
    )],
    [qw(
	SETUP_USER_EDIT
	7
	PUBLIC
	ANONYMOUS
	user/new
	undef
	Setup::Admin
    )],
    [qw(
	SETUP_CLUB_CREATE
	8
        ANY_USER
        USER
        club/created
	CreateClub
	Setup::Finish
    )],
    [qw(
	SETUP_INTRO
	9
	PUBLIC
	ANONYMOUS
	club/setup
	undef
	Setup::Intro
    )],
    [qw(
	CLUB_MAIL_FORWARD
	10
        CLUB
        ANONYMOUS
        :
	ForwardClubMail
	undef
    )],
    [qw(
	USER_MAIL_FORWARD
	11
        USER
        ANONYMOUS
        :
	ForwardUserMail
	undef
    )],
    [qw(
	SETUP_CLUB_EDIT
	12
        ANY_USER
        USER
        club/new
	undef
	Setup::Club
    )],
    [qw(
	TEST_VIEW
	13
        PUBLIC
        ANONYMOUS
        test
	undef
	HTML::View::Test
    )],
    [qw(
	TEST_FORM
	14
        PUBLIC
        ANONYMOUS
        test/form
	undef
	HTML::View::TestForm
    )],
    [qw(
	CLUB_TEST_VIEW
	15
        CLUB
        MEMBER
        _/test
	undef
	HTML::View::ClubTest
    )],
);
# Fix up undefs to be real undefs
map {map {$_ eq 'undef' && ($_ = undef)} @$_} @_CFG;

__PACKAGE__->compile(
    map {($_->[0], [$_->[1]])} @_CFG
);

=head1 METHODS

=cut

=for html <a name="get_cfg_list"></a>

=head2 static get_cfg_list() : array_ref

ONLY TO BE CALLED BY L<Bivio::Agent::Tasks>.

=cut

sub get_cfg_list {
    return \@_CFG;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
