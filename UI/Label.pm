# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Label;
use strict;
$Bivio::UI::Label::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Label - a mapping of IDs to labels

=head1 SYNOPSIS

    use Bivio::UI::Label;
    Bivio::UI::Label->get_simple($value);

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::UI::Label::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::UI::Label> a list of labels to be used in the text.
The label is looked up with I<from_any> and I<get_short_desc>
is used as the name.

=cut

#=IMPORTS
use Bivio::Type::TaxCategory;

#=VARIABLES
_compile(
#TODO: Should these be dynamically looked up?
    # Common labels
    NONE => [' '],
    PHONE => ['Phone', undef, 'Phone.phone'],
    TAX_ID => ['Tax ID', undef, 'TaxId.tax_id'],
    EMAIL => ['Email', undef, 'Email.email', 'RealmInvite.email'],
    PASSWORD => ['Password', undef, 'RealmOwner.password'],
    OLD_PASSWORD => ['Old Password'],
    NEW_PASSWORD => ['New Password'],
    CONFIRM_NEW_PASSWORD => ['Confirm New'],
    LOGIN => ['Login'],
    SAVE_PASSWORD => ['Save Password'],
    SECURE_MODE => ['Secure Mode'],

    # Address labels
    ADDRESS => ['Address'],
    STREET1 => ['Street1', undef, 'Address.street1'],
    STREET2 => ['Street2', undef, 'Address.street2'],
    CITY => ['City', undef, 'Address.city'],
    STATE => ['State', undef, 'Address.state'],
    ZIP => ['Zip', undef, 'Address.zip'],
    COUNTRY => ['Country', undef, 'Address.country'],

    # Club labels
    CLUB_DISPLAY_NAME => ['Name'],
    CLUB_NAME => ['Club ID'],
    CLUB_USER_TITLE => ['Privileges', undef, 'RealmUser.title'],
    CLUB_USER_CREATION_DATE_TIME => ['Joined', undef,
	'RealmUser.creation_date_time'],
    CLUB_START_DATE => ['Date Club Started', undef, 'Club.start_date'],

    # User labels
    USER_DISPLAY_NAME => ['Name', undef, 'RealmOwner.display_name'],
    USER_NAME => ['User ID', undef],
    NAME_OR_EMAIL => ['User ID or Email'],
    USER_FIRST_NAME => ['First Name', undef, 'User.first_name'],
    USER_MIDDLE_NAME => ['Middle Name', undef, 'User.middle_name'],
    USER_LAST_NAME => ['Last Name', undef, 'User.last_name'],

    # Accounting labels
    TRANSACTION_DATE => ['Transaction Date', undef,
	'RealmTransaction.date_time'],
    VALUATION_DATE => ['Valuation Date', undef,
	'MemberEntry.valuation_date'],
    MULTIPLE_PAYMENT => ['Enter Member Payments'],
    MULTIPLE_FEE => ['Enter Member Fees'],
    AMOUNT => ['Amount', undef, 'Entry.amount'],
    ACCOUNT => ['Account', undef, 'RealmAccountEntry.realm_account_id'],
    REMARK => ['Remark', undef, 'RealmTransaction.remark'],
    DEFAULT_REMARK => ['Default Remark'],
    MEMBER_SPECIFIC_REMARK => ['Member Specific Remark'],
    REALM_INSTRUMENT_NAME => ['Full Name', undef, 'RealmInstrument.name'],
    SHARES => ['Shares', undef, 'RealmInstrumentEntry.count'],
    COMMISSION => ['Commission'],
    ADMIN_FEE => ['Service Fee'],
    TICKER => ['Ticker', undef, 'Instrument.ticker_symbol',
	'RealmInstrument.ticker_symbol', 'ticker_symbol'],
    INSTRUMENT_TYPE => ['Category', undef, 'RealmInstrument.instrument_type'],
    LOCAL_INSTRUMENTS => ['Unlisted Investments'],
    PRICE_PER_SHARE => ['Price/Share', undef,
	   'RealmInstrumentValuation.price_per_share'],
    NAME_TICKER => ['Name'],
    FED_TAX_FREE => ['Federal Tax Free', undef,
	'RealmInstrument.fed_tax_free'],
    VALUATION_SEARCH_DATE => ['Date'],
    IMPORT_USER_INFO => ['Import User Information'],
    WANT_SSN => ['Social Security Numbers'],
    WANT_PHONE => ['Telephone Numbers'],
    WANT_ADDRESS => ['Addresses'],
    PARTNER_IS_PARTNERSHIP => [
	    'Is a member of this club also a partnership?',
	   undef, 'Tax1065.partner_is_partnership'],
    PARTNERSHIP_IS_PARTNER => [
	    'Is this club a partner in another partnership?',
	    undef, 'Tax1065.partnership_is_partner'],
    CONSOLIDATED_AUDIT => [
	    'Is this partnership subject to the consolidated audit procedures of 6221 through 6223?',
	    undef, 'Tax1065.consolidated_audit'],
    ENTITY_TYPE => ['Entity Type', undef, 'TaxK1.entity_type'],
    PARTNER_TYPE => ['Partner Type', undef, 'TaxK1.partner_type'],
    IRS_CENTER => ['IRS Center', undef, 'TaxK1.irs_center'],
    FOREIGN_PARTNER => ['Foreign Partner', undef, 'TaxK1.foreign_partner'],
    SHORT_TERM_CAPITAL_GAIN => ['Short-Term Capital Gains', undef,
	    Bivio::Type::TaxCategory->SHORT_TERM_CAPITAL_GAIN->get_short_desc],
    MEDIUM_TERM_CAPITAL_GAIN => ['Medium-Term Capital Gains', undef,
	    Bivio::Type::TaxCategory->MEDIUM_TERM_CAPITAL_GAIN
	    ->get_short_desc],
    LONG_TERM_CAPITAL_GAIN => ['Long-Term Capital Gains', undef,
	    Bivio::Type::TaxCategory->LONG_TERM_CAPITAL_GAIN->get_short_desc],
    MISC_INCOME => ['Miscellaneous Income', undef,
	    Bivio::Type::TaxCategory->MISC_INCOME->get_short_desc],
    TOTAL_INCOME => ['Total Income'],
    MISC_EXPENSE => ['Miscellaneous Expense', undef,
	    Bivio::Type::TaxCategory->MISC_EXPENSE->get_short_desc],
    FOREIGN_TAXES => ['Foreign Taxes', undef,
	    Bivio::Type::TaxCategory->FOREIGN_TAX->get_short_desc],
    TOTAL_EXPENSE => ['Total Expense'],
    NET_PROFIT => ['Net Profit/(Loss)'],
    ALLOCATION_METHOD => ['Allocation Method'],
    TAX_FREE_INT => ['Federal Tax Free Interest',
	    Bivio::Type::TaxCategory->FEDERAL_TAX_FREE_INTEREST->get_short_desc
	   ],
    PAID => ['Total Paid'],
    EARNINGS => ["Earnings\nAllocated"],
    ADD_ROWS => ['Add Rows'],
    LOOKUP_BUTTON => ['Symbol Lookup'],
    NEW_UNLISTED => ['New Unlisted'],
    FEE => ['Fee'],
    WITHDRAWAL_TYPE => ['Type'],
    REFRESH => ['Refresh'],

    # NCA Import
    NCADATA => ['NCADATA.DAT'],

    # Menu Titles
    CLUB_ADMIN => ['Administration'],
    CLUB_ACCOUNTING => ['Accounting'],
    CLUB_COMMUNICATIONS => ['Communications'],

    REALM_CHOOSER => ['Select Site'],

    # Tasks
    CLUB_LEGACY_INVITE => ['Bring Members Online'],
    CLUB_LEGACY_SECURITY_RECONCILIATION => ['Identify Listed Investments'],
    CLUB_ACCOUNTING_CLEAR => ['Clear Online Accounting'],
    CLUB_LEGACY_UPLOAD => ['Import NAIC Club Accounting(tm)'],
    CLUB_ADMIN_TOOLS => ['Administration Tools'],
    CLUB_ADMIN_INVITE => ['Add Members'],
    CLUB_HOME => ['Club Site'],
    USER_HOME => ['My Site'],
    CLUB_ACCOUNTING_PAYMENT => ['Payments'],
    CLUB_ACCOUNTING_FEE => ['Fees'],
    LOGOUT => ['Logout'],
    CLUB_ACCOUNTING_LOCAL_VALUATION_DATES => ['Change Past Valuations'],
    GENERAL_PRIVACY => ['Safe and Private'],
    USER_AGREEMENT_TEXT => ['Terms of Service'],
    CLUB_ACCOUNTING_LOCAL_INSTRUMENT => ['New Unlisted Investment'],
    CLUB_ACCOUNTING_INVESTMENT_BUY => ['Record Purchase'],
    CLUB_ACCOUNTING_INVESTMENT_SELL => ['Record Sale'],
    CLUB_ADMIN_MEMBER_ADD => ['Add Members'],
    CLUB_ADMIN_GUEST_INVITE => ['Invite Guests'],
    CLUB_ADMIN_INVITE_LIST => ['Invites'],
    CLUB_ADMIN_USER_LIST => ['Roster'],
    CLUB_COMMUNICATIONS_FILE_READ => ['Files'],
    CLUB_COMMUNICATIONS_MESSAGE_LIST => ['Mail'],
    CLUB_ACCOUNTING_REPORT_INVESTMENT_SALE => ['Investment Sale Gain/(Loss)'],
    CLUB_ACCOUNTING_REPORT_INCOME_EXPENSE_STATEMENT => [
	'Income and Expense Statement'],
    HTTP_DOCUMENT => ['Home Page'],
    HELP => ['Help'],
    CLUB_CREATE => ['Create Club Site'],
    CLUB_ACCOUNTING_TAX99 => ['U.S. Taxes'],
    CLUB_ADMIN_GUEST_2_MEMBER => ['Invite Guest to become Member'],
    CLUB_OPEN_BALANCE => ['Edit Opening Balances'],
    CLUB_MAIL_DELETE => ['Mail Delete'],
    CLUB_ACCOUNTING_MEMBER_WITHDRAWAL => ['Member Withdrawal'],
    CLUB_ADMIN_MEMBER_DELETE => ['Member Delete'],
    CLUB_ADMIN_EXPORT => ['Export Club Data'],
    CLUB_ADMIN_EXPORT_COMPRESSED => ['Compressed'],
    CLUB_ADMIN_EXPORT_PLAIN => ['Plain'],

    # Julie Stav
    JULIE_STAV => ['Julie Stav'],

    # Table Headings
    NAME_HEADING => ['Name'],
    DIVIDEND_HEADING => ['Dividend'],
    INTEREST_HEADING => ['Interest'],
    TAX_FREE_INT_HEADING => ["Tax Free\nInterest"],
    STCG_HEADING => ["Short-Term\nCapital Gains"],
    MTCG_HEADING => ["Medium-Term\nCapital Gains"],
    LTCG_HEADING => ["Long-Term\nCapital Gains"],
    FOREIGN_TAX_HEADING => ["Foreign\nTax"],
    MISC_INCOME_HEADING => ["Misc.\nIncome"],
    MISC_EXPENSE_HEADING => ["Misc.\nExpense"],
    NET_PROFIT_HEADING => ["Net\nProfit"],
    LAST_FIRST_MIDDLE_HEADING => ['Name'],
    PAID_HEADING => ['Paid'],
    UNITS_HEADING => ['Units', undef, 'MemberEntry.units'],
    VALUE_HEADING => ['Value'],
    PERCENT_HEADING => ['Percent'],
    DESCRIPTION_HEADING => ['Description'],
    ACQUISITION_DATE_HEADING => ["Date\nAcquired", undef,
	    'RealmInstrumentEntry.acquisition_Date'],
    SELL_DATE_HEADING => ['Date Sold'],
    SALES_PRICE_HEADING => ['Sales Price'],
    COST_BASIS_HEADING => ['Cost Basis'],
    GAIN_HEADING => ['Gain/(Loss)'],
    REALMACCOUNT_NAME_HEADING => ['Name'],
    LAST_UPDATED_HEADING => ['Last Updated'],
    BALANCE_HEADING => ['Cash Balance'],
    QUANTITY_HEADING => ['Quantity'],
    LAST_VALUATION_DATE_HEADING => ["Valuation\nDate"],
    PERCENT_OF_PORTFOLIO_HEADING => ["Percent of\nPortfolio"],
    SHARES_HEADING => ["Shares\nHeld"],
    COST_PER_SHARE_HEADING => ["Cost Basis\nper Share"],
    TOTAL_COST_HEADING => ["Total\nCost Basis"],
    SHARE_PRICE_HEADING => ["Price per\nShare"],
    TOTAL_VALUE_HEADING => ["Market\nValue"],
    UNREALIZED_GAIN_HEADING => ["Unrealized\nGain/(Loss)"],
    PERCENT_OF_TOTAL_HEADING => ["Percent\nofTotal"],
    CASH_ACCOUNT_HEADING => ['Cash Account'],
    REALMTRANSACTION_DATE_TIME_HEADING => ['Date'],
    REALMTRANSACTION_REMARK_HEADING => ['Remark'],
    ENTRY_AMOUNT_HEADING => ['Amount'],
    REALMINSTRUMENTENTRY_COUNT_HEADING => ['Shares'],
    RECIPIENT_HEADING => ['Recipient'],
    COUNT_HEADING => ['Quantity'],
    CLUB_COST_BASIS_HEADING => ["Club's\nCost Basis"],
    EXEC_HEADING => ['Exec.'],
    ENTRY_ENTRY_TYPE_HEADING => ['Type'],
    ENTRY_TAX_CATEGORY_HEADING => ['Tax'],
    REMARK_HEADING => ['Remark'],
    ACTION_HEADING => ['Action'],
    REALMOWNER_NAME_HEADING => ['Name'],
    MEMBERENTRY_VALUATION_DATE_HEADING => ['Val. Date'],
    MEMBERENTRY_UNITS_HEADING => ['Units'],
    PAID_YTD_HEADING => ["Paid YTD"],
    UNITS_YTD_HEADING => ["Units YTD"],
    TAX_BASIS_HEADING => ["Tax Basis"],

    # HTML Tax attachment label headings
    TAX_DESCRIPTION_OF_PROPERTY_1_HEADING => ['1 (a) Description of property'],
    TAX_DESCRIPTION_OF_PROPERTY_6_HEADING => ['6 (a) Description of property'],
    TAX_ACQUISITION_DATE_HEADING => ['(b) Date acquired'],
    TAX_SELL_DATE_HEADING => ['(c) Date sold'],
    TAX_SALES_PRICE_HEADING => ['(d) Sales price'],
    TAX_COST_BASIS_HEADING => ['(e) Cost or other basis'],
    TAX_GAIN_HEADING => ['(f) Gain or (loss)'],

    # Form Fields
    INVITE_MESSAGE => ['Message'],

    # Misc. Features
    NEW_HARDWARE => ['New Computers'],
);

=head1 METHODS

=cut

=for html <a name="get_simple"></a>

=head2 static get_simple(any value) : string

Returns the "simple" name we use for this label.
You can use any part of the label to do the lookup.

=cut

sub get_simple {
    my($proto, $value) = @_;
    return $proto->from_any($value)->get_short_desc;
}

#=PRIVATE METHODS

# _compile(array cfg)
#
# Inserts numeric ID into the list.
#
sub _compile {
    my(@cfg) = @_;
    my($i) = 1;
    my($skip) = 1;
    foreach my $c (@cfg) {
	next if $skip;
	unshift(@$c, $i++);
    }
    continue {
	$skip = !$skip;
    }
    __PACKAGE__->compile(@cfg);
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
