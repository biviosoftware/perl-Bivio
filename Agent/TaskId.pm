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
    # URLs can be aliases, separated by a colon. However, the first
    # on is returned on get from task id.  See HTTP::Location code.
    #
    # LOGIN privileges mean something special.  It means the task
    # must be executed from an encrypted context.  Only tasks which
    # require the user to enter sensitive information, e.g. passwords,
    # credit cards, should have LOGIN set.
    #
    # ACHTUNG: Any static top level URI names, must be in
    #          Bivio::Type::RealmName::_RESERVED list
    [qw(
	CLUB_MAIL_FORWARD
	1
        CLUB
        MAIL_WRITE
        !
	Bivio::Biz::Action::ForwardClubMail
    )],
    [qw(
	USER_MAIL_FORWARD
	2
        USER
        MAIL_WRITE
        !
	Bivio::Biz::Action::ForwardUserMail
    )],
    # This is the home page task.
    [qw(
	HTTP_DOCUMENT
	3
        GENERAL
        DOCUMENT_READ
        /
	Bivio::Biz::Action::HTTPDocument
    )],
#TODO: MY_CLUB_REDIRECT isn't right if user not part of club.
#      Need a redirect to club or to user's home.
    [qw(
	MY_CLUB_REDIRECT
	4
        GENERAL
        DOCUMENT_READ
        my_club
	Bivio::Biz::Action::MyClubRedirect
        next=CLUB_HOME
    )],
    [qw(
	LOGIN
	5
        GENERAL
        LOGIN
        pub/login
	Bivio::Biz::Model::LoginForm
	Bivio::UI::HTML::General::Login
        next=MY_CLUB_REDIRECT
    )],
    # Must match the start of the tour
    [qw(
        TOUR
        6
        GENERAL
        DOCUMENT_READ
        hm/tour.html
        Bivio::Biz::Action::HTTPDocument
    )],
#7
    [qw(
	LOGOUT
	8
        GENERAL
        ANY_USER
        pub/logout
	Bivio::Biz::Action::Logout
        Bivio::Biz::Action::ClientRedirect->execute_next
        next=HTTP_DOCUMENT
        cancel=USER_HOME
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_LIST
        9
        CLUB
        ACCOUNTING_READ
        _/accounting/accounts:_/accounts
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Model::AccountSummaryList->execute_load_all
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
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Model::InstrumentSummaryList->execute_load_all
        Bivio::UI::HTML::Club::InstrumentList
    )],
    [qw(
        CLUB_ACCOUNTING_MEMBER_LIST
        12
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        _/accounting/members
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Model::MemberSummaryList->execute_load_all
        Bivio::UI::HTML::Club::MemberList
    )],
    # NOTE: This must not be CLUB_ACCOUNTING_REPORT_*, because
    # AccountingReportForm knows the list of accounting reports.
    [qw(
        CLUB_ACCOUNTING_REPORT
        13
        CLUB
        ACCOUNTING_READ
        _/accounting/reports
        Bivio::Biz::Model::AccountingReportForm
        Bivio::UI::HTML::Club::AccountingReport
        next=CLUB_HOME
    )],
    [qw(
        CLUB_ADMIN_USER_LIST
        14
        CLUB
        ADMIN_READ&MEMBER_READ
        _/admin/roster
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
    [qw(
        CLUB_COMMUNICATIONS_MESSAGE_LIST
        16
        CLUB
        MAIL_READ
        _/mail
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
        ADMIN_READ&MEMBER_READ
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
        Bivio::Biz::Action::ReportDate
	Bivio::Biz::Model::AccountValuationList->execute_load_all
	Bivio::Biz::Model::InstrumentValuationList->execute_load_all
	Bivio::UI::HTML::Club::ValuationReport
    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_COMPLETE_JOURNAL
#        22
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        _/accounting/reports/journal
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_TRANSACTION_SUMMARY
#        23
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        _/accounting/reports/transactions
#        Bivio::UI::HTML::Club::Embargoed
#    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_INVESTMENT_SUMMARY
        24
        CLUB
        ACCOUNTING_READ
        _/accounting/reports/investments
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Model::InstrumentSummaryList->execute_load_all
        Bivio::UI::HTML::Club::InstrumentSummaryReport
    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_INVESTMENT_HISTORY
#        25
#        CLUB
#        ACCOUNTING_READ
#        _/accounting/reports/investment-history
#        Bivio::UI::HTML::Club::Embargoed
#    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_MEMBER_SUMMARY
        26
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        _/accounting/reports/members
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Model::MemberSummaryList->execute_load_all
        Bivio::UI::HTML::Club::MemberSummaryReport
    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_MEMBER_STATUS
#        27
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        _/accounting/reports/member-status
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_MEMBER_VALUE
#        28
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        _/accounting/reports/member-value
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_WITHDRAWAL_EARNINGS
#        29
#        CLUB
#        ACCOUNTING_READ
#        _/accounting/reports/withdrawal-earnings
#        Bivio::UI::HTML::Club::Embargoed
#    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_CASH_ACCOUNT_SUMMARY
        30
        CLUB
        ACCOUNTING_READ
        _/accounting/reports/accounts
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Model::AccountSummaryList->execute_load_all
        Bivio::UI::HTML::Club::AccountSummaryReport
    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_CASH_JOURNAL
#        31
#        CLUB
#        ACCOUNTING_READ
#        _/accounting/reports/cash-journal
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_CASH_CONTRIBUTIONS
#        32
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        _/accounting/reports/cash-contributions
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_PETTY_CASH_CONTRIBUTIONS
#        33
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        _/accounting/reports/pettycash-contributions
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_PETTY_CASH_JOURNAL
#        34
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        _/accounting/reports/pettycash-journal
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_DISTRIBUTIONS
#        35
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        _/accounting/reports/distributions
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_INCOME_STATEMENT
#        36
#        CLUB
#        ACCOUNTING_READ
#        _/accounting/reports/income-expense
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_BALANCE_SHEET
#        37
#        CLUB
#        ACCOUNTING_READ
#        _/accounting/reports/balance-sheet
#        Bivio::UI::HTML::Club::Embargoed
#    )],
    [qw(
	GENERAL_PRIVACY
	38
        GENERAL
        DOCUMENT_READ
        hm/safe.html
        Bivio::Biz::Action::HTTPDocument
    )],
    # No actions, just a token for authentication action
    [qw(
        CLUB_MAIL_COMPOSE
        39
        CLUB
        MAIL_WRITE
        !
    )],
    [qw(
        CLUB_ACCOUNTING_MEMBER_DETAIL
        40
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        _/accounting/member/detail
        Bivio::Biz::Model::MemberTransactionList
        Bivio::Biz::Model::RealmUser
        Bivio::Biz::Model::RealmUserList->execute_load_all
        Bivio::UI::HTML::Club::MemberDetail
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_DETAIL
        41
        CLUB
        ACCOUNTING_READ
        _/accounting/investment/detail
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Model::InstrumentTransactionList
        Bivio::Biz::Model::RealmInstrument
        Bivio::Biz::Model::InstrumentSummaryList->execute_load_all
        Bivio::UI::HTML::Club::InstrumentDetail
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_DETAIL
        42
        CLUB
        ACCOUNTING_READ
        _/accounting/account/detail
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Model::AccountTransactionList
        Bivio::Biz::Model::RealmAccount
        Bivio::Biz::Model::RealmAccountList->execute_load_all
        Bivio::UI::HTML::Club::AccountDetail
    )],
    [qw(
        CLUB_ACCOUNTING_MEMBER_PAYMENT
        43
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE
        _/accounting/member/payment
        Bivio::Biz::Model::RealmUser
        Bivio::Biz::Model::SingleDepositForm
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
        Bivio::Biz::Model::RealmAccount
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
        Bivio::Biz::Model::RealmAccount
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
        Bivio::Biz::Model::RealmAccount
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
        Bivio::Biz::Model::RealmAccount
        Bivio::Biz::Model::AccountTransactionForm
        Bivio::UI::HTML::Club::AccountTransaction
        next=CLUB_ACCOUNTING_ACCOUNT_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_DETAIL_BUY
        49
        CLUB
        ACCOUNTING_WRITE
        _/accounting/investment/detail/buy
        Bivio::Biz::Model::RealmInstrument
        Bivio::Biz::Model::RealmValuationAccountList->execute_load_all
        Bivio::Biz::Model::InstrumentBuyForm
        Bivio::UI::HTML::Club::InstrumentBuy
        next=CLUB_ACCOUNTING_INVESTMENT_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_SELL
        50
        CLUB
        ACCOUNTING_WRITE
        _/accounting/investment/sell
        Bivio::Biz::Model::RealmInstrument
        Bivio::Biz::Model::RealmValuationAccountList->execute_load_all
        Bivio::Biz::Model::InstrumentSellForm
        Bivio::UI::HTML::Club::InstrumentSell
        next=CLUB_ACCOUNTING_INVESTMENT_SELL2
        cancel=CLUB_ACCOUNTING_INVESTMENT_DETAIL
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
        JAPAN_SURVEY
        52
        GENERAL
        DOCUMENT_READ
        pub/japan_survey
        Bivio::Biz::Model::JapanSurveyForm
        next=JAPAN_SURVEY_THANKS
        cancel=HTTP_DOCUMENT
    )],
    [qw(
        JAPAN_SURVEY_THANKS
        53
        GENERAL
        DOCUMENT_READ
        hm/thanks_japan.html
	Bivio::Biz::Action::HTTPDocument
    )],
    # This assumes that user always has privileges to edit "self"
    # Technically, this isn't the case.
    [qw(
        CLUB_ADMIN_USER_ADDRESS_EDIT
        54
        CLUB
        DOCUMENT_READ
        _/admin/edit/self/address
        Bivio::Biz::Action::SetUserTarget
        Bivio::Biz::Model::AddressForm
        Bivio::UI::HTML::User::EditAddress
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        CLUB_ADMIN_USER_NAME_EDIT
        55
        CLUB
        DOCUMENT_READ
        _/admin/edit/self/name
        Bivio::Biz::Action::SetUserTarget
        Bivio::Biz::Model::UserNameForm
        Bivio::UI::HTML::User::EditName
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        CLUB_ADMIN_USER_COMM_EDIT
        56
        CLUB
        DOCUMENT_READ
        _/admin/edit/self/phone_email
        Bivio::Biz::Action::SetUserTarget
        Bivio::Biz::Model::CommForm
        Bivio::UI::HTML::User::EditComm
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        CLUB_ADMIN_USER_PASSWORD_EDIT
        57
        CLUB
        DOCUMENT_READ
        _/admin/edit/self/password
        Bivio::Biz::Action::SetUserTarget
        Bivio::Biz::Model::PasswordForm
        Bivio::UI::HTML::User::EditPassword
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        CLUB_COMMUNICATIONS_MESSAGE_ATTACHMENT
        58
        CLUB
        MAIL_READ
        _/mail/attachment
        Bivio::UI::HTML::Club::MessageAttachment
    )],
    # MUST MATCH Bivio::Biz::Action::REALM_REDIRECT
    [qw(
	DEMO_REDIRECT
	59
        GENERAL
        DOCUMENT_READ
        demo
	Bivio::Biz::Action::DemoClubRedirect
        next=CLUB_HOME
    )],
    [qw(
        CLUB_ACCOUNTING_MEMBER_FEE
        60
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE
        _/accounting/member/fee
        Bivio::Biz::Model::RealmUser
        Bivio::Biz::Model::SingleDepositForm
        Bivio::UI::HTML::Club::SingleDeposit
        next=CLUB_ACCOUNTING_MEMBER_DETAIL
    )],
    [qw(
        CLUB_COMMUNICATIONS_MESSAGE_IMAGE_ATTACHMENT
        61
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE
        _/mail/image
        Bivio::UI::HTML::Club::ImageAttachment
    )],
    [qw(
        USER_AGREEMENT
        62
        GENERAL
        DOCUMENT_READ
        !
        Bivio::Biz::Model::UserAgreementForm
        Bivio::UI::HTML::General::UserAgreement
        next=USER_CREATE
        cancel=HTTP_DOCUMENT
    )],
    # This URI must identify the user agreement document file.
    [qw(
        USER_AGREEMENT_TEXT
        63
        GENERAL
        DOCUMENT_READ
        hm/user.html
        Bivio::Biz::Action::HTTPDocument
    )],
    [qw(
        USER_CREATE
        64
        GENERAL
        LOGIN
        pub/create_user
        Bivio::Biz::Model::RealmInvite->check_accept
        Bivio::Biz::Model::CreateUserForm
        Bivio::UI::HTML::General::CreateUser
        next=USER_CREATED
        cancel=HTTP_DOCUMENT
    )],
    # Default page for users, see MY_BIVIO_REDIRECT
    [qw(
        USER_HOME
        65
        USER
        DOCUMENT_READ
        _
        Bivio::UI::HTML::User::Home
    )],
    [qw(
        USER_ADMIN_INFO
        66
        USER
        ADMIN_READ
        _/admin:_/admin/info
        Bivio::UI::HTML::User::AdminInfo
    )],
    [qw(
        USER_CLUB_LIST
        67
        USER
        ADMIN_READ
        _/clubs
        Bivio::Biz::Model::UserClubList
        Bivio::UI::HTML::User::ClubList
    )],
    [qw(
        USER_ADMIN_NAME_EDIT
        68
        USER
        ADMIN_WRITE
        _/admin/edit/name
        Bivio::Biz::Action::SetUserTarget
        Bivio::Biz::Model::UserNameForm
        Bivio::UI::HTML::User::EditName
        next=USER_ADMIN_INFO
    )],
    [qw(
        CLUB_CREATE
        69
        USER
        ADMIN_WRITE
        _/create_club
        Bivio::Biz::Model::CreateClubForm
        Bivio::UI::HTML::User::CreateClub
        next=CLUB_CREATED
    )],
    # Default page for users, see MY_CLUB_REDIRECT
    [qw(
        CLUB_HOME
        70
        CLUB
        DOCUMENT_READ
        _
        Bivio::UI::HTML::Club::Home
    )],
    [qw(
        USER_ADMIN_PASSWORD_EDIT
        71
        USER
        ADMIN_WRITE
        _/admin/edit/password
        Bivio::Biz::Action::SetUserTarget
        Bivio::Biz::Model::PasswordForm
        Bivio::UI::HTML::User::EditPassword
        next=USER_ADMIN_INFO
    )],
    [qw(
        USER_ADMIN_ADDRESS_EDIT
        72
        USER
        ADMIN_WRITE
        _/admin/edit/address
        Bivio::Biz::Action::SetUserTarget
        Bivio::Biz::Model::AddressForm
        Bivio::UI::HTML::User::EditAddress
        next=USER_ADMIN_INFO
    )],
    [qw(
        USER_ADMIN_COMM_EDIT
        73
        USER
        ADMIN_WRITE
        _/admin/edit/phone_email
        Bivio::Biz::Action::SetUserTarget
        Bivio::Biz::Model::CommForm
        Bivio::UI::HTML::User::EditComm
        next=USER_ADMIN_INFO
    )],
    [qw(
	UNKNOWN_MAIL
	74
        GENERAL
        MAIL_WRITE
        !
	Bivio::Biz::Action::HandleUnknownMail
    )],
    [qw(
        CLUB_ADMIN_INVITE
        75
        CLUB
        ADMIN_WRITE
        _/admin/invite
        Bivio::Biz::Model::ClubInviteForm
        Bivio::UI::HTML::Club::Invite
        next=CLUB_ADMIN_INVITE_LIST
    )],
    [qw(
        CLUB_ADMIN_INVITE_LIST
        76
        CLUB
        ADMIN_READ
        _/admin/invitations
        Bivio::Biz::Model::RealmInviteList
        Bivio::UI::HTML::Club::InviteList
    )],
    # This technically doesn't have to be in your domain
    [qw(
        REALM_INVITE_ACCEPT
        77
        GENERAL
        DOCUMENT_READ
        pub/join
        Bivio::Biz::Model::RealmInvite->execute_accept
        Bivio::Biz::Model::RealmInviteAcceptForm
        Bivio::UI::HTML::General::InviteAccept
        cancel=HTTP_DOCUMENT
        next=CLUB_USER_NEW
        NOT_FOUND=REALM_INVITE_NOT_FOUND
    )],
# Another task here which handles does the invite accept part.
# May need multiple tasks, because the cancels will be different
    [qw(
        CLUB_ADMIN_USER_DETAIL
        78
        CLUB
        ADMIN_READ&MEMBER_READ
        _/admin/roster/detail
        Bivio::Biz::Model::ClubUserList
        Bivio::UI::HTML::Club::UserDetail
    )],
    [qw(
        CLUB_ADMIN_USER_ROLE_EDIT
        79
        CLUB
        ADMIN_WRITE&MEMBER_WRITE
        _/admin/roster/role/edit
        Bivio::Biz::Model::ClubUserList
        Bivio::Biz::Model::ClubUserRoleForm
        Bivio::UI::HTML::Club::EditUserRole
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_LOOKUP
        80
        CLUB
        ACCOUNTING_WRITE
        _/accounting/investment/lookup
        Bivio::Biz::Model::InstrumentLookupForm
        Bivio::Biz::Model::InstrumentLookupList
        Bivio::UI::HTML::Club::InstrumentLookup
        next=CLUB_ACCOUNTING_INVESTMENT_LOOKUP
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_BUY
        81
        CLUB
        ACCOUNTING_WRITE
        _/accounting/investment/buy
        Bivio::Biz::Model::RealmValuationAccountList->execute_load_all
        Bivio::Biz::Model::InstrumentBuyForm
        Bivio::UI::HTML::Club::InstrumentBuy
        next=CLUB_ACCOUNTING_INVESTMENT_LIST
    )],
    [qw(
	SUBSTITUTE_USER
	82
        GENERAL
        ADMIN_WRITE
        pub/su
	Bivio::Biz::Model::SubstituteUserForm
	Bivio::UI::HTML::General::SubstituteUser
        next=USER_HOME
        cancel=HTTP_DOCUMENT
    )],
    [qw(
	GENERAL_CONTACT
	83
        GENERAL
        DOCUMENT_READ
        hm/contact.html
        Bivio::Biz::Action::HTTPDocument
    )],
    [qw(
	REALM_REDIRECT
	84
        GENERAL
        ANY_USER
        goto
        Bivio::Biz::Action::RealmRedirect
        next=USER_HOME
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_SELL2
        85
        CLUB
        ACCOUNTING_WRITE
        _/accounting/investment/sell2
        Bivio::Biz::Model::RealmInstrument
        Bivio::Biz::Model::RealmInstrumentLotList
        Bivio::Biz::Model::InstrumentSellForm2
        Bivio::UI::HTML::Club::InstrumentSell2
        next=CLUB_ACCOUNTING_INVESTMENT_LIST
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_TRANSACTION_DELETE
        86
        CLUB
        ACCOUNTING_WRITE
        _/accounting/investment/delete
        Bivio::Biz::Model::TransactionDeleteForm
        Bivio::UI::HTML::Club::TransactionDelete
        next=CLUB_ACCOUNTING_INVESTMENT_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_MEMBER_TRANSACTION_DELETE
        87
        CLUB
        ACCOUNTING_WRITE
        _/accounting/member/delete
        Bivio::Biz::Model::TransactionDeleteForm
        Bivio::UI::HTML::Club::TransactionDelete
        next=CLUB_ACCOUNTING_MEMBER_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_TRANSACTION_DELETE
        88
        CLUB
        ACCOUNTING_WRITE
        _/accounting/account/delete
        Bivio::Biz::Model::TransactionDeleteForm
        Bivio::UI::HTML::Club::TransactionDelete
        next=CLUB_ACCOUNTING_ACCOUNT_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_INCOME
        89
        CLUB
        ACCOUNTING_WRITE
        _/accounting/investment/income
        Bivio::Biz::Model::RealmInstrument
        Bivio::Biz::Model::RealmValuationAccountList->execute_load_all
        Bivio::Biz::Model::InstrumentIncomeForm
        Bivio::UI::HTML::Club::InstrumentIncome
        next=CLUB_ACCOUNTING_INVESTMENT_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_SPLIT
        90
        CLUB
        ACCOUNTING_WRITE
        _/accounting/investment/split
        Bivio::Biz::Model::RealmInstrument
        Bivio::Biz::Model::InstrumentSplitForm
        Bivio::UI::HTML::Club::InstrumentSplit
        next=CLUB_ACCOUNTING_INVESTMENT_DETAIL
    )],
    [qw(
        REALM_INVITE_NOT_FOUND
        91
        GENERAL
        DOCUMENT_READ
        !
        Bivio::UI::HTML::General::InviteNotFound
    )],
    [qw(
        USER_CREATED
        92
        GENERAL
        DOCUMENT_READ
        !
        Bivio::UI::Mail::UserCreated
        Bivio::Biz::Model::RealmInviteAcceptForm->execute_or_cancel
        Bivio::Biz::Action::ClientRedirect->execute_next
        next=CLUB_USER_NEW
        cancel=USER_NEW
    )],
    [qw(
        USER_NEW
        93
        USER
        DOCUMENT_READ
        _/new
        Bivio::UI::HTML::User::New
    )],
    [qw(
        CLUB_USER_NEW
        94
        CLUB
        DOCUMENT_READ
        _/new_user
        Bivio::Biz::Model::RealmUser->execute_auth_user
        Bivio::UI::HTML::Club::UserNew
    )],
    [qw(
        CLUB_CREATED
        95
        CLUB
        DOCUMENT_READ
        _/new
        Bivio::Biz::Model::RealmUser->execute_auth_user
        Bivio::UI::HTML::Club::New
    )],
    [qw(
        CONNECT_USER_CREATE
        96
        GENERAL
        LOGIN
        pub/connect
        Bivio::Biz::Model::CreateUserForm
        Bivio::UI::HTML::General::CreateUser
        next=CONNECT_USER_CREATED
        cancel=HTTP_DOCUMENT
    )],
    [qw(
        CONNECT_USER_CREATED
        97
        GENERAL
        DOCUMENT_READ
        !
        Bivio::UI::Mail::UserCreated
        Bivio::Biz::Action::ClientRedirect->execute_next
        next=CONNECT_USER_NEW
    )],
#TODO: Put user_new state into cookie
    [qw(
        CONNECT_USER_NEW
        98
        USER
        DOCUMENT_READ
        _/new_connect
        Bivio::UI::HTML::User::New
    )],
    [qw(
        USER_ADMIN_PROFILE_EDIT
        99
        USER
        ADMIN_WRITE
        _/admin/edit/profile
        Bivio::Biz::Model::ConnectSurveyForm
        Bivio::UI::HTML::User::EditProfile
        next=USER_ADMIN_INFO
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
