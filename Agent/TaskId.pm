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

=back

=cut

#=IMPORTS

#=VARIABLES
my(@_CFG) = (
    # Always start enums at 1, so 0 can be reserved for UNKNOWN.
    # DO NOT CHANGE the order of this list, the values may be
    # stored in the database.
    [qw(
	CLUB_MAIL_FORWARD
	1
        CLUB
        ANONYMOUS
        :
	Bivio::Biz::Action::ForwardClubMail
    )],
    [qw(
	USER_MAIL_FORWARD
	2
        USER
        ANONYMOUS
        :
	Bivio::Biz::Action::ForwardUserMail
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_LIST
        9
        CLUB
        MEMBER
        _/accounting/accounts:_/accounts
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_HISTORY
        10
        CLUB
        MEMBER
        _/accounting/history
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_LIST
        11
        CLUB
        MEMBER
        _/accounting/investments:_/investments
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_MEMBER_LIST
        12
        CLUB
        MEMBER
        _/accounting/members
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_LIST
        13
        CLUB
        MEMBER
        _/accounting/reports
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ADMIN_MEMBER_LIST
        14
        CLUB
        MEMBER
        _/admin/members
        Bivio::Biz::Model::ClubUserList
        Bivio::UI::HTML::Club::UserList
    )],
    [qw(
        CLUB_ADMIN_PREFERENCE_LIST
        15
        CLUB
        MEMBER
        _/admin/preferences:_/preferences
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_COMMUNICATIONS_MESSAGE_LIST
        16
        CLUB
        MEMBER
        _:_/communications/mail:_/mail
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_COMMUNICATIONS_MOTION_LIST
        17
        CLUB
        MEMBER
        _/communications/motions:_/motions
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_COMMUNICATIONS_MEMBER_LIST
        18
        CLUB
        MEMBER
        _/communications/rolodex:_/rolodex
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_LIBRARY_LIST
        19
        CLUB
        MEMBER
        _/library
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_SSG
        20
        CLUB
        MEMBER
        _/research/ssg
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
	CLUB_VALUATION_REPORT
	21
        CLUB
        MEMBER
        _/valuation
	Bivio::Biz::Model::AccountValuationList
	Bivio::Biz::Model::InstrumentValuationList
	Bivio::UI::HTML::Club::ValuationReport
    )],
);

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

=for html <a name="is_continuous"></a>

=head2 static is_continuous() : false

Task Ids aren't continuous.  Tasks can go away.

=cut

sub is_continuous {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
