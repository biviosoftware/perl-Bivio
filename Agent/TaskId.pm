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

The syntax of the configuration table is defined as follows:

Always start enums at 1, so 0 can be reserved for UNKNOWN.
DO NOT CHANGE the numbers in this list, the values may be
stored in the database.

URLs can be aliases, separated by a colon (:).  However, the first
on is returned on get from task id.  See HTTP::Location code.

A URI which contains a '?', will have a realm owner name in that
position.

A URI which contains a trailing '*', may have path_info.  These
URIs are severely restricted.  They cannot be set on the GENERAL
realm.  On PROXY realms, they must be exactly /pub/?/I<component>.
On other realms, they must be exactly /?/I<component>.  In both
ases I<component> must be unique in the global URI space.
All of these rules are checked in
L<Bivio::Agent::HTTP::Location|Bivio::Agent::HTTP::Location>.

Use '!' to mean "no uri".

B<Make  the following paragraph true.  We should tag tasks this way so we
have an idea of the tasks which need to be secure, but right
now user decides.>

LOGIN privileges mean something special.  It means the task
must be executed from an encrypted context.  Only tasks which
require the user to enter sensitive information, e.g. passwords,
credit cards, should have LOGIN set.

ACHTUNG: Any static top level URI names, must be in
Bivio::Type::RealmName::_RESERVED list.  In general, avoid top
level names, use C</pub/> names instead.

C<TaskId>s are defined "OBJECT_VERB", so they sort nicely.  The list of
tasks defined in this module is:

=over 4

=back

=cut

#=IMPORTS

#=VARIABLES
my(@_CFG) = (
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
#TODO: MY_CLUB_SITE isn't right if user not part of club.
#      Need a redirect to club or to user's home.
    [qw(
	MY_CLUB_SITE
	4
        GENERAL
        ANY_USER
        pub/my_club_site
	Bivio::Biz::Action::MyClubRedirect
        next=CLUB_HOME
    )],
    [qw(
	LOGIN
	5
        GENERAL
        LOGIN
        pub/login
	Bivio::Biz::Action::Logout
	Bivio::Biz::Model::LoginForm
	Bivio::UI::HTML::General::Login
        next=MY_CLUB_SITE
    )],
    # Must match the start of the tour
    [qw(
        TOUR
        6
        GENERAL
        DOCUMENT_READ
        hm/tour_new/index.html
        Bivio::Biz::Action::HTTPDocument
    )],
#TODO: This is only temporary (ha!).  It names the demo_club
#      as an HTTP_DOCUMENT.  It shouldn't never be executed.
    #
    [qw(
	LOGOUT
	8
        GENERAL
        DOCUMENT_READ
        pub/logout
	Bivio::Biz::Action::Logout
        Bivio::Biz::Action::ClientRedirect->execute_next
        next=HTTP_DOCUMENT
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_LIST
        9
        CLUB
        ACCOUNTING_READ
        ?/accounting/accounts:?/accounts
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Action::LocalDateHack
        Bivio::Biz::Model::AccountSummaryList->execute_load_all
        Bivio::UI::HTML::Club::AccountList
    )],
    [qw(
        CLUB_ACCOUNTING_HISTORY
        10
        CLUB
        ACCOUNTING_READ
        ?/accounting/history
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_LIST
        11
        CLUB
        ACCOUNTING_READ
        ?/accounting/investments:?/investments
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Action::LocalDateHack
        Bivio::Biz::Model::InactiveForm
        Bivio::Biz::Model::InstrumentSummaryList->execute_load_all
        Bivio::UI::HTML::Club::InstrumentList
        next=CLUB_ACCOUNTING_INVESTMENT_LIST
    )],
    [qw(
        CLUB_ACCOUNTING_MEMBER_LIST
        12
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        ?/accounting/members
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Action::LocalDateHack
        Bivio::Biz::Model::InactiveForm
        Bivio::Biz::Model::MemberSummaryList->execute_load_all
        Bivio::UI::HTML::Club::MemberList
        next=CLUB_ACCOUNTING_MEMBER_LIST
    )],
    # NOTE: This must not be CLUB_ACCOUNTING_REPORT_*, because
    # AccountingReportForm knows the list of accounting reports with
    # a pattern match.
    [qw(
        CLUB_ACCOUNTING_REPORT
        13
        CLUB
        ACCOUNTING_READ
        ?/accounting/reports
        Bivio::Biz::Model::AccountingReportForm
        Bivio::UI::HTML::Club::AccountingReport
        next=CLUB_HOME
    )],
    [qw(
        CLUB_ADMIN_USER_LIST
        14
        CLUB
        ADMIN_READ&MEMBER_READ
        ?/admin/roster
        Bivio::Biz::Model::InactiveForm
        Bivio::Biz::Model::ClubUserList->execute_load_all
        Bivio::UI::HTML::Club::UserList
        next=CLUB_ADMIN_USER_LIST
    )],
    [qw(
        CLUB_ADMIN_PREFERENCE_LIST
        15
        CLUB
        ADMIN_READ
        ?/admin/preferences:?/preferences
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_COMMUNICATIONS_MESSAGE_LIST
        16
        CLUB
        MAIL_READ
        ?/mail
        Bivio::Biz::Model::MessageList
        Bivio::UI::HTML::Club::MessageList

    )],
    [qw(
        CLUB_COMMUNICATIONS_MOTION_LIST
        17
        CLUB
        MOTION_READ
        ?/motions
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_COMMUNICATIONS_MEMBER_LIST
        18
        CLUB
        ADMIN_READ&MEMBER_READ
        ?/rolodex
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_LIBRARY_LIST
        19
        CLUB
        DOCUMENT_READ
        ?/library
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
        CLUB_SSG
        20
        CLUB
        FINANCIAL_DATA_READ
        ?/research/ssg
        Bivio::UI::HTML::Club::Embargoed
    )],
    [qw(
	CLUB_ACCOUNTING_REPORT_VALUATION_STATEMENT
	21
        CLUB
        ACCOUNTING_READ
        ?/accounting/reports/valuation
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Action::LocalDateHack
	Bivio::Biz::Model::AccountValuationList->execute_load_all
	Bivio::Biz::Model::InstrumentValuationList->execute_load_all
	Bivio::UI::HTML::Club::ValuationReport
    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_COMPLETE_JOURNAL
#        22
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        ?/accounting/reports/journal
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_TRANSACTION_SUMMARY
#        23
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        ?/accounting/reports/transactions
#        Bivio::UI::HTML::Club::Embargoed
#    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_INVESTMENT_SUMMARY
        24
        CLUB
        ACCOUNTING_READ
        ?/accounting/reports/investments
        Bivio::Biz::Model::InactiveForm->execute_active_only
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Action::LocalDateHack
        Bivio::Biz::Model::InstrumentSummaryList->execute_load_all
        Bivio::UI::HTML::Club::InstrumentSummaryReport
        next=CLUB_ACCOUNTING_REPORT_INVESTMENT_SUMMARY
    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_INVESTMENT_HISTORY
#        25
#        CLUB
#        ACCOUNTING_READ
#        ?/accounting/reports/investment-history
#        Bivio::UI::HTML::Club::Embargoed
#    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_MEMBER_SUMMARY
        26
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        ?/accounting/reports/members
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Action::LocalDateHack
        Bivio::Biz::Model::MemberSummaryList->execute_load_all
        Bivio::UI::HTML::Club::MemberSummaryReport
        next=CLUB_ACCOUNTING_REPORT_MEMBER_SUMMARY
    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_MEMBER_STATUS
#        27
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        ?/accounting/reports/member-status
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_MEMBER_VALUE
#        28
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        ?/accounting/reports/member-value
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_WITHDRAWAL_EARNINGS
#        29
#        CLUB
#        ACCOUNTING_READ
#        ?/accounting/reports/withdrawal-earnings
#        Bivio::UI::HTML::Club::Embargoed
#    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_CASH_ACCOUNT_SUMMARY
        30
        CLUB
        ACCOUNTING_READ
        ?/accounting/reports/accounts
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Action::LocalDateHack
        Bivio::Biz::Model::AccountSummaryList->execute_load_all
        Bivio::UI::HTML::Club::AccountSummaryReport
    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_CASH_JOURNAL
#        31
#        CLUB
#        ACCOUNTING_READ
#        ?/accounting/reports/cash-journal
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_CASH_CONTRIBUTIONS
#        32
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        ?/accounting/reports/cash-contributions
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_PETTY_CASH_CONTRIBUTIONS
#        33
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        ?/accounting/reports/pettycash-contributions
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_PETTY_CASH_JOURNAL
#        34
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        ?/accounting/reports/pettycash-journal
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_DISTRIBUTIONS
#        35
#        CLUB
#        ACCOUNTING_READ&MEMBER_READ
#        ?/accounting/reports/distributions
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_INCOME_STATEMENT
#        36
#        CLUB
#        ACCOUNTING_READ
#        ?/accounting/reports/income-expense
#        Bivio::UI::HTML::Club::Embargoed
#    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_BALANCE_SHEET
#        37
#        CLUB
#        ACCOUNTING_READ
#        ?/accounting/reports/balance-sheet
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
#TODO: Probably should be TargetRealm->execute_this_member, but difficult to
#      use right now.
    [qw(
        CLUB_ACCOUNTING_MEMBER_DETAIL
        40
        CLUB
        ACCOUNTING_READ&MEMBER_READ
        ?/accounting/member/detail
        Bivio::Biz::Model::MemberTransactionList
        Bivio::Biz::Model::RealmUser
        Bivio::Biz::Model::AllMemberList->execute_load_all
        Bivio::UI::HTML::Club::MemberDetail
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_DETAIL
        41
        CLUB
        ACCOUNTING_READ
        ?/accounting/investment/detail
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Model::InstrumentTransactionList
        Bivio::Biz::Model::RealmInstrument
        Bivio::Biz::Model::RealmInstrumentList->execute_load_all
        Bivio::UI::HTML::Club::InstrumentDetail
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_DETAIL
        42
        CLUB
        ACCOUNTING_READ
        ?/accounting/account/detail
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
        ?/accounting/member/payment
        Bivio::Biz::Model::RealmUserList
        Bivio::Biz::Action::TargetRealm->execute_this_member
        Bivio::Type::EntryType->execute_member_payment
        Bivio::Biz::Model::RealmAccountList->execute_load_all
        Bivio::Biz::Model::SingleDepositForm
        Bivio::UI::HTML::Club::SingleDeposit
        next=CLUB_ACCOUNTING_MEMBER_LIST
    )],
    [qw(
        CLUB_COMMUNICATIONS_MESSAGE_DETAIL
        44
        CLUB
        MAIL_READ
        ?/mail/msg
        Bivio::Biz::Model::MessageList
        Bivio::UI::HTML::Club::MessageDetail
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_INTEREST
        45
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/account/interest
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
        ?/accounting/account/dividend
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
        ?/accounting/account/income
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
        ?/accounting/account/expense
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
        ?/accounting/investment/detail/buy
        Bivio::Biz::Model::RealmInstrument
        Bivio::Biz::Model::RealmValuationAccountList->execute_load_all
        Bivio::Biz::Model::InstrumentBuyForm
        Bivio::UI::HTML::Club::ExistingInstrumentBuy
        next=CLUB_ACCOUNTING_INVESTMENT_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_SELL
        50
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/investment/sell
        Bivio::Biz::Model::RealmInstrument
        Bivio::Biz::Model::RealmValuationAccountList->execute_load_all
        Bivio::Biz::Model::InstrumentSellForm
        Bivio::UI::HTML::Club::InstrumentSell
        next=CLUB_ACCOUNTING_INVESTMENT_SELL2
        cancel=CLUB_ACCOUNTING_INVESTMENT_LIST
    )],
    [qw(
        JAPAN_SURVEY
        52
        GENERAL
        DOCUMENT_READ
        pub/japan_survey
        Bivio::Biz::Model::JapanSurveyForm
        Bivio::Biz::Action::ClientRedirect->JAPAN_SURVEY_TEXT
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
    [qw(
        CLUB_ADMIN_SELF_ADDRESS_EDIT
        54
        CLUB
        DOCUMENT_READ
        ?/admin/edit/self/address
        Bivio::Biz::Action::TargetRealm->execute_auth_user
        Bivio::Biz::Model::AddressForm
        Bivio::UI::HTML::Realm::EditAddress
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        CLUB_ADMIN_SELF_NAME_EDIT
        55
        CLUB
        DOCUMENT_READ
        ?/admin/edit/self/name
        Bivio::Type::NameEdit->execute_both
        Bivio::Biz::Action::TargetRealm->execute_auth_user
        Bivio::Biz::Model::UserNameForm
        Bivio::UI::HTML::User::EditName
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        CLUB_ADMIN_SELF_PHONE_EDIT
        56
        CLUB
        DOCUMENT_READ
        ?/admin/edit/self/phone
        Bivio::Biz::Action::TargetRealm->execute_auth_user
        Bivio::Biz::Model::PhoneForm
        Bivio::UI::HTML::Realm::EditPhone
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        CLUB_ADMIN_SELF_PASSWORD_EDIT
        57
        CLUB
        DOCUMENT_READ&LOGIN
        ?/admin/edit/self/password
        Bivio::Biz::Action::TargetRealm->execute_auth_user
        Bivio::Biz::Model::PasswordForm
        Bivio::UI::HTML::User::EditPassword
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        CLUB_COMMUNICATIONS_MESSAGE_ATTACHMENT
        58
        CLUB
        MAIL_READ
        ?/mail/attachment
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
        ?/accounting/member/fee
        Bivio::Biz::Model::RealmUserList
        Bivio::Biz::Action::TargetRealm->execute_this_member
        Bivio::Type::EntryType->execute_member_payment_fee
        Bivio::Biz::Model::RealmValuationAccountList->execute_load_all
	Bivio::Biz::Model::SingleDepositForm
        Bivio::UI::HTML::Club::SingleDeposit
        next=CLUB_ACCOUNTING_MEMBER_LIST
    )],
    [qw(
        CLUB_COMMUNICATIONS_MESSAGE_IMAGE_ATTACHMENT
        61
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE
        ?/mail/image
        Bivio::UI::HTML::Club::ImageAttachment
    )],
    [qw(
        JAPAN_SURVEY_TEXT
        62
        GENERAL
        DOCUMENT_READ
        hm/intro_japan.html
	Bivio::Biz::Action::HTTPDocument
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
        ?
        Bivio::UI::HTML::User::Home
    )],
    [qw(
        USER_ADMIN_INFO
        66
        USER
        ADMIN_READ
        ?/admin:?/admin/info
        Bivio::UI::HTML::User::AdminInfo
    )],
    [qw(
        USER_CLUB_LIST
        67
        USER
        ADMIN_READ
        ?/clubs
        Bivio::Biz::Model::UserClubList
        Bivio::UI::HTML::User::ClubList
    )],
    [qw(
        USER_ADMIN_NAME_EDIT
        68
        USER
        ADMIN_WRITE
        ?/admin/edit/name
        Bivio::Type::NameEdit->execute_both
        Bivio::Biz::Action::TargetRealm->execute_auth_realm
        Bivio::Biz::Model::UserNameForm
        Bivio::UI::HTML::User::EditName
        next=USER_ADMIN_INFO
    )],
    [qw(
        CLUB_CREATE
        69
        USER
        ADMIN_WRITE
        ?/create_club
        Bivio::Biz::Model::CreateClubForm
        Bivio::UI::HTML::User::CreateClub
        next=CLUB_CREATED
    )],
    [qw(
        CLUB_HOME
        70
        CLUB
        DOCUMENT_READ
        ?
        Bivio::UI::HTML::Club::Home
    )],
    [qw(
        USER_ADMIN_PASSWORD_EDIT
        71
        USER
        ADMIN_WRITE&LOGIN
        ?/admin/edit/password
        Bivio::Biz::Action::TargetRealm->execute_auth_realm
        Bivio::Biz::Model::PasswordForm
        Bivio::UI::HTML::User::EditPassword
        next=USER_ADMIN_INFO
    )],
    [qw(
        USER_ADMIN_ADDRESS_EDIT
        72
        USER
        ADMIN_WRITE
        ?/admin/edit/address
        Bivio::Biz::Action::TargetRealm->execute_auth_realm
        Bivio::Biz::Model::AddressForm
        Bivio::UI::HTML::Realm::EditAddress
        next=USER_ADMIN_INFO
    )],
    [qw(
        USER_ADMIN_PHONE_EDIT
        73
        USER
        ADMIN_WRITE
        ?/admin/edit/phone
        Bivio::Biz::Action::TargetRealm->execute_auth_realm
        Bivio::Biz::Model::PhoneForm
        Bivio::UI::HTML::Realm::EditPhone
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
        CLUB_ADMIN_INVITE_LIST
        76
        CLUB
        ADMIN_READ&MEMBER_READ
        ?/admin/invitations
        Bivio::Biz::Model::RealmInviteList->execute_load_all
        Bivio::Biz::Model::RealmUserList->execute_load_all
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
        Bivio::Biz::Model::Lock->execute_accounting_import
        Bivio::Biz::Model::RealmInviteAcceptForm
        Bivio::UI::HTML::General::InviteAccept
        cancel=HTTP_DOCUMENT
        next=CLUB_USER_NEW
        NOT_FOUND=REALM_INVITE_NOT_FOUND
    )],
# Another task here which handles does the invite accept part.
# May need multiple tasks, because the cancels will be different
    # We use RealmUserList and ClubUserList, because this is a detail
    # and we need the whole list for the chooser and the individual
    # validated by the normal "this" loading.
    [qw(
        CLUB_ADMIN_USER_DETAIL
        78
        CLUB
        ADMIN_READ&MEMBER_READ
        ?/admin/roster/detail
        Bivio::Biz::Model::ClubUserList
        Bivio::Biz::Action::TargetRealm->execute_this
        Bivio::Biz::Model::RealmUserList->execute_load_all
        Bivio::UI::HTML::Club::UserDetail
    )],
    [qw(
        CLUB_ADMIN_MEMBER_TITLE_EDIT
        79
        CLUB
        ADMIN_WRITE&MEMBER_WRITE
        ?/admin/edit/member/privileges
        Bivio::Biz::Model::ClubUserList
        Bivio::Biz::Action::TargetRealm->execute_this_real_member
        Bivio::Biz::Model::ClubMemberTitleForm
        Bivio::UI::HTML::Club::EditMemberTitle
        next=CLUB_ADMIN_USER_DETAIL
    )],
#TODO: not implemented
#        Bivio::Biz::Action::TargetRealm->execute_this_real_member
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_LOOKUP
        80
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/investment/lookup
        Bivio::Biz::Model::InstrumentLookupForm
        Bivio::Biz::Model::InstrumentLookupList
        Bivio::UI::HTML::Club::InstrumentLookup
        next=CLUB_ACCOUNTING_INVESTMENT_LIST
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_BUY
        81
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/investment/buy
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
        DOCUMENT_READ
        goto
        Bivio::Biz::Action::RealmRedirect
        next=USER_HOME
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_SELL2
        85
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/investment/sell2
        Bivio::Biz::Model::RealmInstrument
        Bivio::Biz::Model::InstrumentSellForm2
        Bivio::UI::HTML::Club::InstrumentSell2
        next=CLUB_ACCOUNTING_INVESTMENT_LIST
    )],
#TODO: Cancel is broken on detail, because FormModel doesn't do the right thing
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_TRANSACTION_DELETE
        86
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/investment/delete
        Bivio::Biz::Model::Entry
        Bivio::Biz::Model::TransactionDeleteForm
        Bivio::UI::HTML::Club::TransactionDelete
        next=CLUB_ACCOUNTING_INVESTMENT_LIST
    )],
#TODO: Cancel is broken on detail, because FormModel doesn't do the right thing
    [qw(
        CLUB_ACCOUNTING_MEMBER_TRANSACTION_DELETE
        87
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE
        ?/accounting/member/delete
        Bivio::Biz::Model::Entry
        Bivio::Biz::Model::TransactionDeleteForm
        Bivio::UI::HTML::Club::TransactionDelete
        next=CLUB_ACCOUNTING_MEMBER_LIST
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_TRANSACTION_DELETE
        88
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/account/delete
        Bivio::Biz::Model::Entry
        Bivio::Biz::Model::TransactionDeleteForm
        Bivio::UI::HTML::Club::TransactionDelete
        next=CLUB_ACCOUNTING_ACCOUNT_LIST
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_INCOME
        89
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/investment/income
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
        ?/accounting/investment/split
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
        Bivio::UI::HTML::ErrorPages->execute_invite_not_found
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
        ?/new
        Bivio::Biz::Model::Email->execute_load
        Bivio::UI::HTML::User::New
    )],
    [qw(
        CLUB_USER_NEW
        94
        CLUB
        DOCUMENT_READ
        ?/new_user
        Bivio::Biz::Model::RealmUser->execute_auth_user
        Bivio::Biz::Model::Email->execute_auth_user
        Bivio::UI::HTML::Club::UserNew
    )],
    [qw(
        CLUB_CREATED
        95
        CLUB
        DOCUMENT_READ
        ?/new
        Bivio::Biz::Model::RealmUser->execute_auth_user
        Bivio::UI::HTML::Club::New
    )],
    [qw(
        CONNECT_USER_CREATE
        96
        GENERAL
        LOGIN
        pub/connect
        Bivio::Biz::Action::ConnectCheckUser
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
        ?/new_connect
        Bivio::Biz::Model::Email->execute_load
        Bivio::UI::HTML::User::New
    )],
    [qw(
        USER_ADMIN_PROFILE_EDIT
        99
        USER
        ADMIN_WRITE
        ?/admin/edit/profile
        Bivio::Biz::Model::ConnectSurveyForm
        Bivio::UI::HTML::User::EditProfile
        next=USER_ADMIN_PROFILE_EDIT_DONE
        cancel=USER_ADMIN_INFO
    )],
    [qw(
        CONNECT_LOGIN
        100
        GENERAL
        ANY_USER
        pub/connect/login
        Bivio::Biz::Action::ClientRedirect->execute_next
        next=USER_ADMIN_PROFILE_EDIT
    )],
    [qw(
        CLUB_ACCOUNTING_MEMBER_WITHDRAWAL
        101
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE&ADMIN_WRITE
        ?/accounting/member/withdrawal
        Bivio::Biz::Model::RealmUserList
        Bivio::Biz::Action::TargetRealm->execute_this_member
        Bivio::Biz::Model::RealmValuationAccountList->execute_load_all
        Bivio::Biz::Model::MemberWithdrawalForm
        Bivio::UI::HTML::Club::MemberWithdrawal
        next=CLUB_ACCOUNTING_MEMBER_DETAIL
    )],
    [qw(
        CLUB_ADMIN_NAME_EDIT
        102
        CLUB
        ADMIN_WRITE
        ?/admin/edit/name
        Bivio::Biz::Action::NotDemoClub
        Bivio::Biz::Action::TargetRealm->execute_auth_realm
        Bivio::Biz::Model::ClubNameForm
        Bivio::UI::HTML::Club::EditName
        next=CLUB_ADMIN_INFO
    )],
    [qw(
        DEMO_CLUB_ACTION_FORBIDDEN
        103
        CLUB
        DOCUMENT_READ
        !
        Bivio::UI::HTML::ErrorPages->execute_demo_club_action_forbidden
    )],
#TODO: Shadow realms have no data protection.  We may need to
#      have a second security check in SetProxyRealm or something.
#      For now, the list is small so easy to manage.
    [qw(
        CELEBRITY_MESSAGE_LIST
        104
        PROXY
        DOCUMENT_READ
        pub/?
        Bivio::Biz::Model::MessageList
        Bivio::UI::HTML::Celebrity::MessageList
    )],
    [qw(
        CELEBRITY_MESSAGE_DETAIL
        105
        PROXY
        DOCUMENT_READ
        pub/?/msg
        Bivio::Biz::Model::MessageList
        Bivio::UI::HTML::Celebrity::MessageDetail
    )],
    # No actions, just a token for authentication action
    [qw(
        CELEBRITY_MAIL_COMPOSE
        106
        PROXY
        DOCUMENT_READ
        !
    )],
    [qw(
        DEFAULT_ERROR_REDIRECT_FORBIDDEN
        107
        GENERAL
        DOCUMENT_READ
        !
        Bivio::UI::HTML::ErrorPages->execute_forbidden
    )],
    [qw(
        USER_ADMIN_PROFILE_EDIT_DONE
        108
        USER
        ADMIN_WRITE
        ?/admin/edit/profile/done
        Bivio::UI::HTML::User::EditProfileDone
    )],
    [qw(
        CLUB_COMMUNICATIONS_FILE_READ
        109
        CLUB
        DOCUMENT_READ
        ?/files/*
        Bivio::Type::FileVolume->execute_file
        Bivio::Biz::Model::FilePathList
        Bivio::Biz::Action::FileDownload->execute_if_file
        Bivio::Biz::Model::FileTreeList
        Bivio::UI::HTML::Widget::FilePageHeading
        Bivio::UI::HTML::Club::FileTree
    )],
    [qw(
        CLUB_COMMUNICATIONS_FILE_DELETE
        110
        CLUB
        DOCUMENT_WRITE
        ?/file_delete/*
        Bivio::Type::FileVolume->execute_file
        Bivio::Biz::Model::FilePathList
        Bivio::Biz::Model::FileDeleteForm
        Bivio::UI::HTML::Widget::FilePageHeading
        Bivio::UI::HTML::Club::FileDelete
	next=CLUB_COMMUNICATIONS_FILE_READ
    )],
    [qw(
        CLUB_COMMUNICATIONS_FILE_UPLOAD
        111
        CLUB
        DOCUMENT_WRITE
        ?/file_upload/*
        Bivio::Type::FileVolume->execute_file
        Bivio::Biz::Model::FilePathList
        Bivio::Biz::Model::FileUploadForm
        Bivio::UI::HTML::Widget::FilePageHeading
        Bivio::UI::HTML::Club::FileUpload
	next=CLUB_COMMUNICATIONS_FILE_READ
    )],
#112
    [qw(
        CLUB_COMMUNICATIONS_FILE_REPLACE
        113
        CLUB
        DOCUMENT_WRITE
        ?/file_replace/*
        Bivio::Type::FileVolume->execute_file
        Bivio::Biz::Model::FilePathList
        Bivio::Biz::Model::FileUploadForm
        Bivio::UI::HTML::Widget::FilePageHeading->execute_no_links
        Bivio::UI::HTML::Club::FileReplace
	next=CLUB_COMMUNICATIONS_FILE_READ
    )],
    [qw(
        CLUB_COMMUNICATIONS_FILE_CREATE_DIRECTORY
        114
        CLUB
        DOCUMENT_WRITE
        ?/new_file_folder/*
        Bivio::Type::FileVolume->execute_file
        Bivio::Biz::Model::FilePathList
        Bivio::Biz::Model::CreateDirectoryForm
        Bivio::UI::HTML::Widget::FilePageHeading
        Bivio::UI::HTML::Club::CreateDirectory
	next=CLUB_COMMUNICATIONS_FILE_READ
    )],
    [qw(
        CLUB_ACCOUNTING_MEMBER_OPENING_BALANCE
        115
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE
        ?/accounting/member/openbal
        Bivio::Biz::Model::RealmUserList
        Bivio::Biz::Action::TargetRealm->execute_this_member
        Bivio::Biz::Model::MemberOpeningBalanceForm
        Bivio::UI::HTML::Club::MemberOpeningBalance
        next=CLUB_ACCOUNTING_MEMBER_DETAIL
    )],
    [qw(
        CLUB_ACCOUNTING_INVESTMENT_OPENING_BALANCE
        116
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/investment/openbal
        Bivio::Biz::Model::InstrumentOpeningBalanceForm
        Bivio::UI::HTML::Club::InstrumentOpeningBalance
        next=CLUB_ACCOUNTING_INVESTMENT_LIST
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_OPENING_BALANCE
        117
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/account/openbal
        Bivio::Biz::Model::AccountOpeningBalanceForm
        Bivio::UI::HTML::Club::AccountOpeningBalance
        next=CLUB_ACCOUNTING_ACCOUNT_LIST
    )],
    [qw(
        CLUB_ACCOUNTING_ACCOUNT_TRANSFER
        118
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/account/transfer
        Bivio::Biz::Model::RealmValuationAccountList->execute_load_all
        Bivio::Biz::Model::AccountTransferForm
        Bivio::UI::HTML::Club::AccountTransfer
        next=CLUB_ACCOUNTING_ACCOUNT_LIST
    )],
    [qw(
        DEFAULT_ERROR_REDIRECT_NO_RESOURCES
        119
        GENERAL
        DOCUMENT_READ
        !
        Bivio::UI::HTML::ErrorPages->execute_no_resources
    )],
    [qw(
        CLUB_ADMIN_ADDRESS_EDIT
        120
        CLUB
        ADMIN_WRITE
        ?/admin/edit/address
        Bivio::Biz::Action::TargetRealm->execute_auth_realm
        Bivio::Biz::Model::AddressForm
        Bivio::UI::HTML::Realm::EditAddress
        next=CLUB_ADMIN_INFO
    )],
    [qw(
        CLUB_ADMIN_MEMBER_ADDRESS_EDIT
        121
        CLUB
        ADMIN_WRITE&MEMBER_WRITE
        ?/admin/edit/member/address
        Bivio::Biz::Model::ClubUserList
        Bivio::Biz::Action::TargetRealm->execute_this_member_or_withdrawn
        Bivio::Biz::Model::AddressForm
        Bivio::UI::HTML::Realm::EditAddress
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        CLUB_ADMIN_SELF_TAX_ID_EDIT
        122
        CLUB
        DOCUMENT_READ&LOGIN
        ?/admin/edit/self/tax_id
        Bivio::Biz::Action::TargetRealm->execute_auth_user
        Bivio::Biz::Model::TaxIdForm
        Bivio::UI::HTML::Realm::EditTaxId
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        CLUB_ADMIN_MEMBER_TAX_ID_EDIT
        123
        CLUB
        ADMIN_WRITE&MEMBER_WRITE&LOGIN
        ?/admin/edit/member/tax_id
        Bivio::Biz::Model::ClubUserList
        Bivio::Biz::Action::TargetRealm->execute_this_member_or_withdrawn
        Bivio::Biz::Model::TaxIdForm
        Bivio::UI::HTML::Realm::EditTaxId
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        USER_ADMIN_TAX_ID_EDIT
        124
        USER
        ADMIN_WRITE&LOGIN
        ?/admin/edit/member/tax_id
        Bivio::Biz::Action::TargetRealm->execute_auth_realm
        Bivio::Biz::Model::TaxIdForm
        Bivio::UI::HTML::Realm::EditTaxId
        next=USER_ADMIN_INFO
    )],
    [qw(
        CLUB_ADMIN_TAX_ID_EDIT
        125
        CLUB
        ADMIN_WRITE&LOGIN
        ?/admin/edit/tax_id
        Bivio::Biz::Action::TargetRealm->execute_auth_realm
        Bivio::Biz::Model::TaxIdForm
        Bivio::UI::HTML::Realm::EditTaxId
        next=CLUB_ADMIN_INFO
    )],
    [qw(
        CLUB_ADMIN_INFO
        126
        CLUB
        ADMIN_READ
        ?/admin/info
        Bivio::UI::HTML::Club::AdminInfo
    )],
    [qw(
        USER_ADMIN_EMAIL_EDIT
        127
        USER
        ADMIN_WRITE
        ?/admin/edit/email
        Bivio::Biz::Action::TargetRealm->execute_auth_realm
        Bivio::Biz::Model::EmailForm
        Bivio::UI::HTML::Realm::EditEmail
        next=USER_ADMIN_INFO
    )],
    [qw(
        CLUB_ADMIN_SELF_EMAIL_EDIT
        128
        CLUB
        DOCUMENT_READ
        ?/admin/edit/self/email
        Bivio::Biz::Action::TargetRealm->execute_auth_user
        Bivio::Biz::Model::EmailForm
        Bivio::UI::HTML::Realm::EditEmail
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        CLUB_ADMIN_PHONE_EDIT
        129
        CLUB
        ADMIN_WRITE
        ?/admin/edit/phone
        Bivio::Biz::Action::TargetRealm->execute_auth_realm
        Bivio::Biz::Model::PhoneForm
        Bivio::UI::HTML::Realm::EditPhone
        next=CLUB_ADMIN_INFO
    )],
    # Order of lists is important.  RealmAccountList must be last
    [qw(
        CLUB_ACCOUNTING_PAYMENT
        130
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE
        ?/accounting/payment
        Bivio::Type::EntryType->execute_member_payment
        Bivio::Biz::Model::MemberList->execute_load_all
        Bivio::Biz::Model::RealmAccountList->execute_load_all
        Bivio::Biz::Model::MultipleDepositForm
        Bivio::UI::HTML::Club::MultiplePayment
        next=CLUB_ACCOUNTING_MEMBER_LIST
    )],
    # Order of lists is important.  RealmValuationAccountList must be last
    [qw(
        CLUB_ACCOUNTING_FEE
        131
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE
        ?/accounting/fee
        Bivio::Type::EntryType->execute_member_payment_fee
        Bivio::Biz::Model::MemberList->execute_load_all
        Bivio::Biz::Model::RealmValuationAccountList->execute_load_all
        Bivio::Biz::Model::MultipleDepositForm
        Bivio::UI::HTML::Club::MultipleFee
        next=CLUB_ACCOUNTING_MEMBER_LIST
    )],
#    [qw(
#        TEST_JOB
#        132
#        CLUB
#        ACCOUNTING_WRITE&MEMBER_WRITE
#        ?/test_job
#        Bivio::Biz::Model::Lock->execute_ACCOUNTING_IMPORT
#        Bivio::Biz::Action::TestJob
#        next=CLUB_HOME
#    )],
    [qw(
        CLUB_LEGACY_UPLOAD
        133
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE&ADMIN_WRITE
        ?/accounting/import
        Bivio::Biz::Action::NotDemoClub
        Bivio::Biz::Model::Club->execute_load
        Bivio::Biz::Model::Lock->execute_accounting_import
        Bivio::Biz::Model::LegacyClubUploadForm
        Bivio::UI::HTML::Club::LegacyClubUpload
        next=CLUB_LEGACY_SECURITY_RECONCILIATION
        cancel=CLUB_ADMIN_TOOLS
    )],
    [qw(
        CLUB_LEGACY_INVITE
        134
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE&ADMIN_WRITE
        ?/admin/invite/offline_members
        Bivio::Biz::Action::NotDemoClub
        Bivio::Biz::Model::ActiveShadowMemberList->execute_load_all
        Bivio::Biz::Model::InviteMemberListForm
        Bivio::UI::HTML::Club::InviteMemberList
        next=CLUB_ADMIN_USER_LIST
    )],
    [qw(
        CLUB_LEGACY_SECURITY_RECONCILIATION
        135
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/identify/listed_investments
        Bivio::Biz::Action::NotDemoClub
        Bivio::Biz::Model::RealmLocalSecurityList->execute_load_all
        Bivio::Biz::Model::ImportedSecurityReconciliationForm
        Bivio::UI::HTML::Club::ImportedSecurityReconciliation
        next=CLUB_LEGACY_INVITE
        cancel=CLUB_ADMIN_TOOLS
    )],
    [qw(
        CLUB_ACCOUNTING_CLEAR
        136
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE&ADMIN_WRITE
        ?/accounting/clear
        Bivio::Biz::Action::NotDemoClub
        Bivio::Biz::Model::Lock->execute_accounting_import
        Bivio::Biz::Model::Club->execute_load
        Bivio::Biz::Model::ClearAccountingForm
        Bivio::UI::HTML::Club::ClearAccounting
        next=CLUB_ADMIN_TOOLS
    )],
    [qw(
        CLUB_ADMIN_TOOLS
        137
        CLUB
        ACCOUNTING_WRITE
        ?/admin/tools
        Bivio::Biz::Model::RealmLocalSecurityList->execute_load_all
        Bivio::Biz::Model::LocalValuationYearList->execute_load_all
        Bivio::UI::HTML::Club::AdminTools
    )],
    [qw(
        CLUB_LEGACY_UPLOAD_PROCESSOR
        138
        CLUB
        ACCOUNTING_WRITE&MEMBER_WRITE
        !
        Bivio::Biz::Model::Lock->execute_accounting_import
        Bivio::Biz::Action::AccountingImport
    )],
    [qw(
        CLUB_ACCOUNTING_LOCAL_INSTRUMENT
        139
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/unlisted/new
        Bivio::Biz::Model::LocalInstrumentForm
        Bivio::UI::HTML::Club::LocalInstrument
        next=CLUB_ACCOUNTING_INVESTMENT_BUY
    )],
    [qw(
        CLUB_ACCOUNTING_LOCAL_VALUATION_DATES
        140
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/valuation/dates
        Bivio::Biz::Model::LocalValuationYearList->execute_load_all
        Bivio::Biz::Model::LocalValuationDateList
        Bivio::UI::HTML::Club::LocalValuationDates
    )],
    [qw(
        CLUB_ACCOUNTING_LOCAL_PRICES
        141
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/valuation/prices
        Bivio::Biz::Model::LocalPriceList
        Bivio::Biz::Model::LocalPricesForm
        Bivio::UI::HTML::Club::LocalPrices
        next=CLUB_ACCOUNTING_LOCAL_VALUATION_DATES
    )],
    [qw(
        CLUB_ACCOUNTING_LOCAL_VALUE
        142
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/valuation/new
        Bivio::Biz::Model::LocalPriceList
        Bivio::Biz::Model::LocalPricesForm
        Bivio::UI::HTML::Club::LocalPrices
        next=CLUB_ACCOUNTING_INVESTMENT_LIST
    )],
    [qw(
        DEFAULT_ERROR_REDIRECT_UPDATE_COLLISION
        143
        GENERAL
        DOCUMENT_READ
        !
        Bivio::UI::HTML::ErrorPages->execute_update_collision
    )],
    [qw(
        CLUB_ADMIN_MEMBER_PHONE_EDIT
        145
        CLUB
        ADMIN_WRITE&MEMBER_WRITE
        ?/admin/edit/member/phone
        Bivio::Biz::Model::ClubUserList
        Bivio::Biz::Action::TargetRealm->execute_this_member_or_withdrawn
        Bivio::Biz::Model::PhoneForm
        Bivio::UI::HTML::Realm::EditPhone
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        CLUB_ADMIN_MEMBER_NAME_EDIT
        146
        CLUB
        ADMIN_WRITE&MEMBER_WRITE
        ?/admin/edit/member/name
        Bivio::Type::NameEdit->execute_display_only
        Bivio::Biz::Model::ClubUserList
        Bivio::Biz::Action::TargetRealm->execute_this_member_or_withdrawn
        Bivio::Biz::Model::UserNameForm
        Bivio::UI::HTML::Club::EditUserName
        next=CLUB_ADMIN_USER_DETAIL
    )],
    [qw(
        CLUB_ADMIN_MEMBER_ADD
        147
        CLUB
        ADMIN_WRITE&MEMBER_WRITE
        ?/admin/add/members
        Bivio::Biz::Model::NumberedList->execute_load_page
        Bivio::Biz::Model::AddMemberListForm
        Bivio::UI::HTML::Club::AddMemberList
        next=CLUB_ADMIN_USER_LIST
    )],
    [qw(
        CLUB_ADMIN_GUEST_INVITE
        148
        CLUB
        ADMIN_WRITE
        ?/admin/invite/guests
        Bivio::Biz::Model::NumberedList->execute_load_page
        Bivio::Biz::Model::InviteGuestListForm
        Bivio::UI::HTML::Club::InviteGuestList
        next=CLUB_ADMIN_INVITE_LIST
        cancel=CLUB_ADMIN_USER_LIST
    )],
    [qw(
        DEFAULT_ERROR_REDIRECT_CORRUPT_QUERY
        149
        GENERAL
        DOCUMENT_READ
        !
        Bivio::UI::HTML::ErrorPages->execute_corrupt_query
    )],
    [qw(
        DEFAULT_ERROR_REDIRECT_VERSION_MISMATCH
        150
        GENERAL
        DOCUMENT_READ
        !
        Bivio::UI::HTML::ErrorPages->execute_corrupt_query
    )],
    [qw(
        CLUB_ADMIN_INVITE_DELETE
        151
        CLUB
        ADMIN_WRITE
        ?/admin/invite/delete
        Bivio::Biz::Model::RealmInvite
        Bivio::Biz::Model::DeleteInviteForm
        next=CLUB_ADMIN_INVITE_LIST
    )],
    [qw(
        CLUB_ADMIN_INVITE_RESEND
        152
        CLUB
        ADMIN_WRITE
        ?/admin/invite/resend
        Bivio::Biz::Model::RealmInvite
        Bivio::Biz::Model::ResendInviteForm
        Bivio::UI::HTML::Club::ResendInvite
        next=CLUB_ADMIN_INVITE_LIST
    )],
    [qw(
        CLUB_ADMIN_GUEST_DELETE
        153
        CLUB
        ADMIN_WRITE
        ?/admin/guest/delete
        Bivio::Biz::Model::ClubUserList
        Bivio::Biz::Model::DeleteGuestForm
        Bivio::UI::HTML::Club::DeleteGuest
        next=CLUB_ADMIN_USER_LIST
    )],
    [qw(
        CLUB_ADMIN_GUEST_2_MEMBER
        154
        CLUB
        ADMIN_WRITE
        ?/admin/guest2member
        Bivio::Biz::Model::ClubUserList
        Bivio::Biz::Model::Guest2MemberForm
        Bivio::UI::HTML::Club::Guest2Member
        next=CLUB_ADMIN_INVITE_LIST
        cancel=CLUB_ADMIN_USER_LIST
    )],
    [qw(
        CLUB_GUEST_2_MEMBER_ACCEPT
        155
        CLUB
        ADMIN_READ&MEMBER_READ
        ?/guest/make/member
        Bivio::Biz::Model::RealmInvite
        Bivio::Biz::Model::Guest2MemberAcceptForm
        Bivio::UI::HTML::Club::Guest2MemberAccept
        next=CLUB_ADMIN_USER_LIST
        NOT_FOUND=REALM_INVITE_NOT_FOUND
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_INVESTMENT_SALE
        156
        CLUB
        ACCOUNTING_READ
        ?/accounting/reports/investment_sale
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Action::LocalDateHack
        Bivio::Type::ScheduleDParams->execute_show_distributions
        Bivio::Biz::Model::InstrumentSaleList->execute_load_all
        Bivio::UI::HTML::Club::InstrumentSaleReport
        next=CLUB_ACCOUNTING_REPORT_INVESTMENT_SALE
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_INCOME_EXPENSE_STATEMENT
        157
        CLUB
        ACCOUNTING_READ
        ?/accounting/reports/income_and_expense
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Action::LocalDateHack
        Bivio::Biz::Model::IncomeAndExpenseList->execute_load_all
        Bivio::UI::HTML::Club::IncomeAndExpenseReport
        next=CLUB_ACCOUNTING_REPORT_INCOME_EXPENSE_STATEMENT
    )],
    # Forces user to login and then redirects to USER_HOME
    [qw(
        MY_SITE
        158
        GENERAL
        ANY_USER
        pub/my_site
        Bivio::Biz::Action::ClientRedirect->execute_next
        next=USER_HOME
    )],
    [qw(
        HELP
        159
        GENERAL
        DOCUMENT_READ
        hp/index.html
        Bivio::Biz::Action::HTTPDocument
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_MEMBER_ALLOCATION
        160
        CLUB
        ACCOUNTING_READ
        ?/accounting/reports/allocations
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Action::LocalDateHack
        Bivio::Biz::Model::MemberAllocationList->execute_load_all
        Bivio::UI::HTML::Club::MemberAllocationReport
        next=CLUB_ACCOUNTING_REPORT_MEMBER_ALLOCATION
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_MISC_INCOME_AND_DEDUCTIONS
        161
        CLUB
        ACCOUNTING_READ
        ?/accounting/reports/income_and_deductions
        Bivio::Biz::Action::ReportDate
        Bivio::Biz::Action::LocalDateHack
        Bivio::Biz::Model::PortfolioDeductionList->execute_load_all
        Bivio::Biz::Model::PortfolioIncomeList->execute_load_all
        Bivio::UI::HTML::Club::MiscIncomeAndDeductions
        next=CLUB_ACCOUNTING_REPORT_MISC_INCOME_AND_DEDUCTIONS
    )],
    [qw(
        CLUB_ACCOUNTING_TAX99_F1065
        162
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/tax99/f1065
        Bivio::Biz::Action::ReportDate->execute1999
        Bivio::Type::ScheduleDParams->execute_hide_distributions
        Bivio::Biz::Model::InstrumentSaleList->execute_load_all
        Bivio::Biz::Model::ScheduleDForm
        Bivio::Biz::Model::IncomeAndExpenseList->execute_load_all
        Bivio::Biz::Model::F1065Form
        Bivio::UI::HTML::FormDump
        next=CLUB_ACCOUNTING_TAX99_F1065
    )],
    [qw(
        CLUB_ACCOUNTING_TAX99_F1065K1
        163
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/tax99/f1065k1
        Bivio::Biz::Model::RealmUser
        Bivio::Biz::Action::ReportDate->execute1999
        Bivio::Biz::Model::IncomeAndExpenseList->execute_load_all
        Bivio::Biz::Model::WithdrawnAllocationList->execute_load_all
        Bivio::Biz::Model::MemberAllocationList->execute_load_all
        Bivio::Biz::Model::F1065K1Form
        Bivio::UI::HTML::FormDump
        next=CLUB_ACCOUNTING_TAX99_F1065
    )],
    [qw(
        CLUB_ACCOUNTING_TAX99
        164
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/tax99
        Bivio::Biz::Action::ReportDate->execute1999
        Bivio::Biz::Model::MemberTaxList->execute_load_all
        Bivio::UI::HTML::Club::Tax99
    )],
#    [qw(
#        CLUB_ACCOUNTING_REPORT_MEMBER_WITHDRAWALS
#        165
#        CLUB
#        ACCOUNTING_WRITE
#        ?/accounting/reports/withdrawals
#    )],
    [qw(
        CLUB_ACCOUNTING_TAX99_1065_PARAMETERS
        166
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/tax99/f1065/parameters
        Bivio::Biz::Model::F1065ParametersForm
        Bivio::UI::HTML::Club::F1065Parameters
        next=CLUB_ACCOUNTING_TAX99
    )],
    [qw(
        CLUB_ACCOUNTING_TAX99_K1_PARAMETERS
        167
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/tax99/k1/parameters
        Bivio::Biz::Action::ReportDate->execute1999
        Bivio::Biz::Model::MemberTaxList->execute_load_all
        Bivio::Biz::Model::F1065K1ParametersForm
        Bivio::UI::HTML::Club::F1065K1Parameters
        next=CLUB_ACCOUNTING_TAX99
    )],
    [qw(
        CLUB_ACCOUNTING_TAX99_SCHEDULE_D
        168
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/tax99/schedule_d
        Bivio::Biz::Action::ReportDate->execute1999
        Bivio::Type::ScheduleDParams->execute_hide_distributions
        Bivio::Biz::Model::InstrumentSaleList->execute_load_all
        Bivio::Biz::Model::ScheduleDForm
        Bivio::UI::HTML::Tax::ScheduleD
        next=CLUB_ACCOUNTING_TAX99_SCHEDULE_D
    )],
    [qw(
        CLUB_ACCOUNTING_TAX99_INCOME
        169
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/tax99/income
        Bivio::Biz::Action::ReportDate->execute1999
        Bivio::Biz::Model::PortfolioIncomeList->execute_load_all
        Bivio::UI::HTML::Tax::PortfolioIncome
        next=CLUB_ACCOUNTING_TAX99_INCOME
    )],
    [qw(
        CLUB_ACCOUNTING_TAX99_DISTRIBUTIONS
        170
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/tax99/distributions
        Bivio::Biz::Action::ReportDate->execute1999
        Bivio::Biz::Action::LocalDateHack
        Bivio::Biz::Model::CashWithdrawalList->execute_load_all
        Bivio::Biz::Model::InstrumentWithdrawalList->execute_load_all
        Bivio::UI::HTML::Tax::MemberDistributions
    )],
    [qw(
        CLUB_ACCOUNTING_REPORT_DATE_TEST
        171
        CLUB
        ACCOUNTING_READ
        ?/accounting/report_date_test
        Bivio::Biz::Model::AccountingReportForm
        Bivio::UI::HTML::DateTest
        next=CLUB_ACCOUNTING_REPORT_DATE_TEST
    )],
    [qw(
        CLUB_ACCOUNTING_TAX99_DEDUCTIONS
        172
        CLUB
        ACCOUNTING_WRITE
        ?/accounting/tax99/deductions
        Bivio::Biz::Action::ReportDate->execute1999
        Bivio::Biz::Model::PortfolioDeductionList->execute_load_all
        Bivio::UI::HTML::Tax::PortfolioDeductions
        next=CLUB_ACCOUNTING_TAX99_DEDUCTIONS
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
