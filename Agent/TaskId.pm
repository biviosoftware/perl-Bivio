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
    # DO NOT CHANGE the numbers in this list, the values may be
    # stored in the database.
    #
    # ACHTUNG: Any static top level URI names, must be in
    #          Bivio::Type::RealmName::_RESERVED list
    [qw(
	CLUB_MAIL_FORWARD
	1
        CLUB
        MAIL_WRITE
        :
	Bivio::Biz::Action::ForwardClubMail
    )],
    [qw(
	USER_MAIL_FORWARD
	2
        USER
        MAIL_WRITE
        :
	Bivio::Biz::Action::ForwardUserMail
    )],
    [qw(
	HTTP_DOCUMENT
	3
        GENERAL
        DOCUMENT_READ
        /
	Bivio::Biz::Action::HTTPDocument
    )],
    [qw(
	MY_CLUB_REDIRECT
	4
        GENERAL
        DOCUMENT_READ
        my_club
	Bivio::Biz::Action::MyClubRedirect
        next=CLUB_COMMUNICATIONS_MESSAGE_LIST
    )],
    [qw(
	LOGIN
	5
        GENERAL
        DOCUMENT_READ
        login
	Bivio::Biz::Action::Login
    )],
    [qw(
        MY_CLUB_NOT_FOUND
        6
        GENERAL
        DOCUMENT_READ
        hm/start.html
        Bivio::Biz::Action::HTTPDocument
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_LIST
        9
        CLUB
        ACCOUNTING_READ
        _/accounting/accounts:_/accounts
        Bivio::Biz::Model::AccountSummaryList
        Bivio::UI::HTML::Club::AccountList
    )],
    [qw(
        CLUB_ACCOUNTING_HISTORY
        10
        CLUB
        ACCOUNTING_READ
        _/accounting/history
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_LIST
        11
        CLUB
        ACCOUNTING_READ
        _/accounting/investments:_/investments
        Bivio::Biz::Model::InstrumentSummaryList
        Bivio::UI::HTML::Club::InstrumentList
    )],
    [qw(
        CLUB_ACCOUNTING_MEMBER_LIST
        12
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        _/accounting/members
        Bivio::Biz::Model::MemberSummaryList
        Bivio::UI::HTML::Club::MemberList
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_LIST
        13
        CLUB
        ACCOUNTING_READ
        _/accounting/reports
        Bivio::UI::HTML::Club::ReportList
    )],
    [qw(
        CLUB_ADMIN_MEMBER_LIST
        14
        CLUB
        MEMBER_READ
        _/admin/members
        Bivio::Biz::Model::ClubUserList
        Bivio::UI::HTML::Club::UserList
    )],
    [qw(
        CLUB_ADMIN_PREFERENCE_LIST
        15
        CLUB
        ADMIN_READ
        _/admin/preferences:_/preferences
        Bivio::UI::HTML::Club::Embargoed
    )],
    # Default page for clubs, see MY_CLUB_REDIRECT
    [qw(
        CLUB_COMMUNICATIONS_MESSAGE_LIST
        16
        CLUB
        MAIL_READ
        _:_/mail
        Bivio::Biz::Model::MessageList
        Bivio::UI::HTML::Club::MessageList

    )],
    [qw(
        CLUB_COMMUNICATIONS_MOTION_LIST
        17
        CLUB
        MOTION_READ
        _/motions
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_COMMUNICATIONS_MEMBER_LIST
        18
        CLUB
        MEMBER_READ
        _/rolodex
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_LIBRARY_LIST
        19
        CLUB
        DOCUMENT_READ
        _/library
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_SSG
        20
        CLUB
        FINANCIAL_DATA_READ
        _/research/ssg
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
	CLUB_ACCOUNTING_REPORT_VALUATION_STATEMENT
	21
        CLUB
        ACCOUNTING_READ
        _/accounting/reports/valuation
	Bivio::Biz::Model::AccountValuationList
	Bivio::Biz::Model::InstrumentValuationList
	Bivio::UI::HTML::Club::ValuationReport
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_COMPLETE_JOURNAL
        22
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        _/accounting/reports/journal
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_TRANSACTION_SUMMARY
        23
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        _/accounting/reports/transactions
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_INVESTMENT_SUMMARY
        24
        CLUB
        ACCOUNTING_READ
        _/accounting/reports/investments
        Bivio::Biz::Model::InstrumentSummaryList
        Bivio::UI::HTML::Club::InstrumentSummaryReport
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_INVESTMENT_HISTORY
        25
        CLUB
        ACCOUNTING_READ
        _/accounting/reports/investment-history
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_MEMBER_SUMMARY
        26
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        _/accounting/reports/members
        Bivio::Biz::Model::MemberSummaryList
        Bivio::UI::HTML::Club::MemberSummaryReport
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_MEMBER_STATUS
        27
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        _/accounting/reports/member-status
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_MEMBER_VALUE
        28
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        _/accounting/reports/member-value
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_WITHDRAWAL_EARNINGS
        29
        CLUB
        ACCOUNTING_READ
        _/accounting/reports/withdrawal-earnings
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_CASH_ACCOUNT_SUMMARY
        30
        CLUB
        ACCOUNTING_READ
        _/accounting/reports/accounts
        Bivio::Biz::Model::AccountSummaryList
        Bivio::UI::HTML::Club::AccountSummaryReport
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_CASH_JOURNAL
        31
        CLUB
        ACCOUNTING_READ
        _/accounting/reports/cash-journal
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_CASH_CONTRIBUTIONS
        32
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        _/accounting/reports/cash-contributions
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_PETTY_CASH_CONTRIBUTIONS
        33
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        _/accounting/reports/pettycash-contributions
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_PETTY_CASH_JOURNAL
        34
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        _/accounting/reports/pettycash-journal
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_DISTRIBUTIONS
        35
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        _/accounting/reports/distributions
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_INCOME_STATEMENT
        36
        CLUB
        ACCOUNTING_READ
        _/accounting/reports/income-expense
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_BALANCE_SHEET
        37
        CLUB
        ACCOUNTING_READ
        _/accounting/reports/balance-sheet
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        SETUP_USER
        38
        GENERAL
        DEBUG_ACTION
        setup/user
        Bivio::Biz::Model::UserForm
        Bivio::UI::HTML::Setup::User
        next=SETUP_USER
    )],
    # No actions, just a token for authentication action
    [qw(
        CLUB_MAIL_COMPOSE
        39
        CLUB
        MAIL_WRITE
        :
    )],
    [qw(
        CLUB_ACCOUNTING_MEMBER_DETAIL
        40
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        _/accounting/member/detail
        Bivio::UI::HTML::Club::MemberDetail
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_DETAIL
        41
        CLUB
        ACCOUNTING_READ
        _/accounting/investment/detail
        Bivio::UI::HTML::Club::InstrumentDetail
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_DETAIL
        42
        CLUB
        ACCOUNTING_READ
        _/accounting/account/detail
        Bivio::Biz::Model::AccountSummaryList
        Bivio::UI::HTML::Club::AccountDetail
    )],
    [qw(
        CLUB_ACCOUNTING_MEMBER_PAYMENT
        43
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE
        _/accounting/member/payment
        Bivio::Biz::Model::SingleDepositForm
        Bivio::Biz::Model::RealmAccountList
        Bivio::UI::HTML::Club::SingleDeposit
        next=CLUB_ACCOUNTING_MEMBER_DETAIL
    )],
    [qw(
        CLUB_COMMUNICATIONS_MESSAGE_DETAIL
        44
        CLUB
        MAIL_READ
        _/mail/msg
        Bivio::Biz::Model::MessageList
        Bivio::UI::HTML::Club::MessageDetail
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_INTEREST
        45
        CLUB
        ACCOUNTING_WRITE
        _/accounting/account/interest
        Bivio::Biz::Model::AccountTransactionForm
        Bivio::UI::HTML::Club::AccountTransaction
        next=CLUB_ACCOUNTING_ACCOUNT_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_DIVIDEND
        46
        CLUB
        ACCOUNTING_WRITE
        _/accounting/account/dividend
        Bivio::Biz::Model::AccountTransactionForm
        Bivio::UI::HTML::Club::AccountTransaction
        next=CLUB_ACCOUNTING_ACCOUNT_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_INCOME
        47
        CLUB
        ACCOUNTING_WRITE
        _/accounting/account/income
        Bivio::Biz::Model::AccountTransactionForm
        Bivio::UI::HTML::Club::AccountTransaction
        next=CLUB_ACCOUNTING_ACCOUNT_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_EXPENSE
        48
        CLUB
        ACCOUNTING_WRITE
        _/accounting/account/expense
        Bivio::Biz::Model::AccountTransactionForm
        Bivio::UI::HTML::Club::AccountTransaction
        next=CLUB_ACCOUNTING_ACCOUNT_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_BUY
        49
        CLUB
        ACCOUNTING_WRITE
        _/accounting/investment/buy
        Bivio::Biz::Model::InstrumentBuyForm
        Bivio::Biz::Model::RealmValuationAccountList
        Bivio::UI::HTML::Club::InstrumentBuy
        next=CLUB_ACCOUNTING_INVESTMENT_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_SELL
        50
        CLUB
        ACCOUNTING_WRITE
        _/accounting/investment/sell
        Bivio::Biz::Model::InstrumentSellForm
        Bivio::Biz::Model::RealmValuationAccountList
        Bivio::UI::HTML::Club::InstrumentSell
        next=CLUB_ACCOUNTING_INVESTMENT_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_VALUATION
        51
        CLUB
        ACCOUNTING_WRITE
        _/accounting/investment/valuation
        Bivio::Biz::Model::InstrumentValuationForm
        Bivio::UI::HTML::Club::InstrumentValuation
        next=CLUB_ACCOUNTING_INVESTMENT_LIST
    )],
    [qw(
	CLUB_ACCOUNTING_REPORT_VALUATION_STATEMENT_PARAMS
	52
        CLUB
        ACCOUNTING_READ
        _/accounting/reports/valuation/date
        Bivio::Biz::Model::ReportDateForm
        Bivio::UI::HTML::Club::ReportDate
        next=CLUB_ACCOUNTING_REPORT_VALUATION_STATEMENT
        cancel=CLUB_ACCOUNTING_REPORT_LIST
    )],
    [qw(
	CLUB_ACCOUNTING_REPORT_INVESTMENT_SUMMARY_PARAMS
	53
        CLUB
        ACCOUNTING_READ
        _/accounting/reports/investments/date
        Bivio::Biz::Model::ReportDateForm
        Bivio::UI::HTML::Club::ReportDate
        next=CLUB_ACCOUNTING_REPORT_INVESTMENT_SUMMARY
        cancel=CLUB_ACCOUNTING_REPORT_LIST
    )],
    [qw(
	CLUB_ACCOUNTING_REPORT_MEMBER_SUMMARY_PARAMS
	54
        CLUB
        ACCOUNTING_READ
        _/accounting/reports/members/date
        Bivio::Biz::Model::ReportDateForm
        Bivio::UI::HTML::Club::ReportDate
        next=CLUB_ACCOUNTING_REPORT_MEMBER_SUMMARY
        cancel=CLUB_ACCOUNTING_REPORT_LIST
    )],
    [qw(
	CLUB_ACCOUNTING_REPORT_CASH_ACCOUNT_SUMMARY_PARAMS
	55
        CLUB
        ACCOUNTING_READ
        _/accounting/reports/accounts/date
        Bivio::Biz::Model::ReportDateForm
        Bivio::UI::HTML::Club::ReportDate
        next=CLUB_ACCOUNTING_REPORT_CASH_ACCOUNT_SUMMARY
        cancel=CLUB_ACCOUNTING_REPORT_LIST
    )],
    [qw(
        SETUP_CLUB
        56
        GENERAL
        DEBUG_ACTION
        setup/club
        Bivio::Biz::Model::ClubForm
        Bivio::UI::HTML::Setup::Club
        next=SETUP_MEMBER
    )],
    [qw(
        SETUP_MEMBER
        57
        GENERAL
        DEBUG_ACTION
        setup/member
        Bivio::Biz::Model::MemberForm
        Bivio::UI::HTML::Setup::Member
        next=SETUP_MEMBER
    )],
    [qw(
        CLUB_COMMUNICATIONS_MESSAGE_ATTACHMENT
        58
        CLUB
        MAIL_READ
        _/mail/attachment
        Bivio::UI::HTML::Club::MessageAttachment

    )],
    [qw(
	DEMO_REDIRECT
	59
        GENERAL
        DOCUMENT_READ
        demo
	Bivio::Biz::Action::DemoClubRedirect
        next=CLUB_COMMUNICATIONS_MESSAGE_LIST
    )],
    [qw(
        CLUB_ACCOUNTING_MEMBER_FEE
        60
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE
        _/accounting/member/fee
        Bivio::Biz::Model::SingleDepositForm
        Bivio::Biz::Model::RealmValuationAccountList
        Bivio::UI::HTML::Club::SingleDeposit
        next=CLUB_ACCOUNTING_MEMBER_DETAIL
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
