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
    OLD_PASSWORD => ['Current Password'],
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
    ADDRESS_COUNTRY => ['Country'],
    ADDRESS_STATE => ['State'],

    # Form Buttons
    APPLY_CHANGES_BUTTON => [' Apply Changes '],
    CALCULATE_BUTTON => ['Calculate'],
    CANCEL_BUTTON => ['Cancel'],
    CHANGE_PREFERENCES_BUTTON => ['Change Preferences'],
    CREATE_BUTTON => ['Create'],
    I_ACCEPT_BUTTON => [' I Accept '],
    I_DECLINE_BUTTON => [' I Decline '],
    LOGIN_BUTTON => ['Login'],
    LOOKUP_BUTTON => ['Symbol Lookup', undef, 'symbol_lookup_button'],
    LOOKUP_BUTTON_HEADING => ['Symbol'],
    LOT_BUTTON => ['Lots'],
    NEXT_BUTTON => [' Next '],
    OK_BUTTON => ['  OK  '],
    REFRESH_BUTTON => ['Refresh'],
    REGISTER_BUTTON => ['Register'],
    SEND_BUTTON => [' Send '],
    TICKER_BUTTON => ['Ticker'],
    UNLISTED_BUTTON => ['New Unlisted', undef, 'new_unlisted',
	    'new_unlisted_button'],

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
    USER_LAST_NAME_SORT => ['Last Name', undef, 'User.last_name_sort'],

    # Accounting labels
    TRANSACTION_DATE => ['Transaction Date', undef,
	'RealmTransaction.date_time'],
    VALUATION_DATE => ['Member Valuation Date', undef,
	'MemberEntry.valuation_date', 'member_valuation_date'],
    MULTIPLE_PAYMENT => ['Enter Member Payments'],
    MULTIPLE_FEE => ['Enter Member Fees'],
    AMOUNT => ['Amount', undef, 'Entry.amount'],
    ACCOUNT => ['Account', undef, 'RealmAccountEntry.realm_account_id'],
    REMARK => ['Remark', undef, 'RealmTransaction.remark'],
    DEFAULT_REMARK => ['Default Remark'],
    MEMBER_SPECIFIC_REMARK => ['Member Specific Remark'],
    REALM_INSTRUMENT_NAME => ['Full Name', undef, 'RealmInstrument.name'],
    SHARES => ['Shares', undef, 'RealmInstrumentEntry.count', 'quantity'],
    COMMISSION => ['Commission'],
    ADMIN_FEE => ['Service Fee'],
    TICKER => ['Ticker', undef, 'Instrument.ticker_symbol',
	    'RealmInstrument.ticker_symbol', 'ticker_symbol',
	    'source_ticker_symbol'],
    INSTRUMENT_TYPE => ['Category', undef, 'RealmInstrument.instrument_type'],
    LOCAL_INSTRUMENTS => ['Unlisted Investments'],
    PRICE_PER_SHARE => ['Price/Share', undef,
	   'RealmInstrumentValuation.price_per_share', 'share_price'],
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
	    Bivio::Type::TaxCategory->FOREIGN_TAX->get_short_desc,
	    'foreign_taxes_paid'],
    TOTAL_EXPENSE => ['Total Expense'],
    NET_PROFIT => ['Net Profit/(Loss)'],
    ALLOCATION_METHOD => ['Allocation Method'],
    TAX_FREE_INT => ['Federal Tax Free Interest',
	    Bivio::Type::TaxCategory->FEDERAL_TAX_FREE_INTEREST->get_short_desc
	   ],
    PAID => ['Total Paid'],
    EARNINGS => ["Earnings\nAllocated"],
    ADD_ROWS => ['Add Rows'],
    FEE => ['Fee'],
    WITHDRAWAL_TYPE => ['Type'],
    SELECTED => ['Selected'],
    ACQUISITION_DATE => ['Acquisition Date'],
    COST_PER_SHARE => ['Cost/Share'],
    TRANSFER_VALUATION_DATE => ['Transfer Valuation Date'],
    WITHDRAWAL_VALUE => ['Withdrawal Value'],
    WITHDRAWAL_FEE => ['Withdrawal Fee'],
    WITHDRAWAL_AMOUNT => ['Withdrawal Amount'],
    CASH_WITHDRAWN => ['Cash'],
    INSTRUMENT_FMV => ["Investments' FMV"],
    WITHDRAWAL_ADJUSTMENT => ['Post-Withdrawal Adjustment'],
    MEMBER_TAX_BASIS => ["Member's Tax Basis"],
    WITHDRAWAL_ALLOCATIONS => ["Current Income Allocation"],
    MEMBER_INSTRUMENT_COST_BASIS => ["Stock"],
    UNIT_VALUE => ['Unit Value'],
    UNITS_WITHDRAWN => ['Units Withdrawn'],
    GENERATE => ['Generate', undef, 'generate2'],
    REPORT_DATE => ['Report Date'],
    REPORT_YEAR => ['Report Year'],
    TASK_ID => ['Task', undef, 'task_id2'],
    FEE_PERCENT => ['Percent Fee Type'],
    MONTH => ['Month'],
    PRE_WITHDRAWAL_BASIS => ["Member's Basis Before Withdrawal"],
    ADJUSTED_BASIS => ['(A)  Adjusted basis'],
    BASIS_WITHDRAWN => ['(B)  Total'],
    WITHDRAWAL_REALIZED_GAIN => ["Gain/(Loss) Realized on Withdrawal (B)-(A)"],
    BASIS_AFTER_WITHDRAWAL => ["Member's Basis After Withdrawal"],
    RETURN_SINCE => ['Return Since'],
    RETURN_TO => ['Return To'],
    PREPARATION_DATE => ['Report Preparation Date'],
    REMAINING_BASIS => ['Remaining Basis Percentage'],
    INCOME_TYPE => ['Distribution Type'],
    PARENT_PRICE => ['Parent Price/Share'],
    CHILD_PRICE => ['Child Price/Share'],
    FRACTIONAL_SHARE_CASH => ['Cash Received'],
    ACQUIRING_TICKER_SYMBOL => ['Acquiring Ticker'],
    PAYMENT => ['Payment'],
    SOURCE_ACCOUNT_ID => ['Source Account'],
    TARGET_ACCOUNT_ID => ['Target Account'],
    EASY_ACTIONS => ['Easy Actions'],

    # Accounting Reports (Tasks sorted alphabetically)
    CLUB_ACCOUNTING_REPORT => ['Accounting Reports'],
    CLUB_ACCOUNTING_REPORT_CASH_ACCOUNT_SUMMARY => ['Account Report'],
    CLUB_ACCOUNTING_REPORT_COMPARISON_PERFORMANCE => [
	    'Performance Comparison Report'],
    CLUB_ACCOUNTING_REPORT_INCOME_EXPENSE_STATEMENT => [
	'Income and Expense Report'],
    CLUB_ACCOUNTING_REPORT_INVESTMENT_PERFORMANCE => [
	'Investment Performance Report'],
    CLUB_ACCOUNTING_REPORT_INVESTMENT_PERFORMANCE_DETAIL => [
	'Investment Performance Detail Report'],
    CLUB_ACCOUNTING_REPORT_INVESTMENT_SALE => [
	'Capital Gains and Losses Report'],
    CLUB_ACCOUNTING_REPORT_INVESTMENT_SUMMARY => ['Investment Report'],
    CLUB_ACCOUNTING_REPORT_MEMBER_ALLOCATION => [
	'Member Tax Allocation Report'],
    CLUB_ACCOUNTING_REPORT_MEMBER_PERFORMANCE => ['Member Performance Report'],
    CLUB_ACCOUNTING_REPORT_MEMBER_PERFORMANCE_DETAIL => [
	    'Member Performance Detail Report'],
    CLUB_ACCOUNTING_REPORT_MEMBER_STATUS => ['Member Status Report'],
    CLUB_ACCOUNTING_REPORT_MEMBER_SUMMARY => ['Member Report'],
    CLUB_ACCOUNTING_REPORT_MEMBER_WITHDRAWAL => ['Member Withdrawal Report'],
    # Not really a report, but on the report page
    CLUB_ACCOUNTING_REPORT_MEMBER_WITHDRAWAL_LIST => [
	'Member Withdrawal Summary'],
    CLUB_ACCOUNTING_REPORT_MISC_INCOME_AND_DEDUCTIONS => [
	'Miscellaneous Income and Deductions Report'],
    CLUB_ACCOUNTING_REPORT_VALUATION_STATEMENT => ['Valuation Report'],

    # NCA Import
    NCADATA => ['NCADATA.DAT'],

    # Menu Titles
    CLUB_ADMIN => ['Administration'],
    CLUB_ACCOUNTING => ['Accounting'],
    CLUB_COMMUNICATIONS => ['Communications'],
    USER_ADMIN => ['Administration'],
    USER_CLUB => ['Clubs'],

    # Page Titles
    TITLE_HOME_PAGE => ['Home'],
    TITLE_SITE => ['bivio'],

    REALM_CHOOSER => ['Select Site'],

    # Tasks (sorted alphabetically)
    CLUB_ACCOUNTING_ACCOUNT_DETAIL => ['Account Detail'],
    CLUB_ACCOUNTING_ACCOUNT_DIVIDEND => ['Account Dividend'],
    CLUB_ACCOUNTING_ACCOUNT_EXPENSE => ['Account Expense'],
    CLUB_ACCOUNTING_ACCOUNT_INCOME => ['Account Income'],
    CLUB_ACCOUNTING_ACCOUNT_INTEREST => ['Account Interest'],
    CLUB_ACCOUNTING_ACCOUNT_LIST => ['Account Summary'],
    CLUB_ACCOUNTING_ACCOUNT_TRANSFER => ['Account Transfer'],
    CLUB_ACCOUNTING_CLEAR => ['Clear Online Accounting'],
    CLUB_ACCOUNTING_FEE => ['Fees'],
    CLUB_ACCOUNTING_INVESTMENT_BUY => ['Record Purchase'],
    CLUB_ACCOUNTING_INVESTMENT_CHARGES_PAID => ['Charges Paid From Dividends'],
    CLUB_ACCOUNTING_INVESTMENT_DETAIL => ['Investment Detail'],
    CLUB_ACCOUNTING_INVESTMENT_INCOME => ['Investment Income'],
    CLUB_ACCOUNTING_INVESTMENT_LIST => ['Investment Summary'],
    CLUB_ACCOUNTING_INVESTMENT_LOT_LIST => ['Investment Lots'],
    CLUB_ACCOUNTING_INVESTMENT_MERGER => ['Investment Merger'],
    CLUB_ACCOUNTING_INVESTMENT_REINVEST => ['Reinvest Income'],
    CLUB_ACCOUNTING_INVESTMENT_SELL => ['Record Sale'],
    CLUB_ACCOUNTING_INVESTMENT_SPINOFF => ['Investment Spin-off'],
    CLUB_ACCOUNTING_INVESTMENT_SPINOFF_BASIS =>
	['Investment Basis Calculator'],
    CLUB_ACCOUNTING_INVESTMENT_SPLIT => ['Stock Split'],
    CLUB_ACCOUNTING_LOCAL_INSTRUMENT => ['New Unlisted Investment'],
    CLUB_ACCOUNTING_LOCAL_VALUATION_DATES => ['Change Past Valuations'],
    CLUB_ACCOUNTING_MEMBER_DETAIL => ['Member Detail'],
    CLUB_ACCOUNTING_MEMBER_LIST => ['Member Summary'],
    CLUB_ACCOUNTING_MEMBER_WITHDRAWAL => ['Member Withdrawal'],
    CLUB_ACCOUNTING_MEMBER_WITHDRAWAL_STOCK => [
	'Member Investment Withdrawal'],
    CLUB_ACCOUNTING_PAYMENT => ['Payments'],
    CLUB_ACCOUNTING_TAX99 => ['U.S. Taxes'],
    CLUB_ACCOUNTING_TAX99_MEMBER_ALLOCATION => [
	'Member Tax Allocation Report'],
    CLUB_ADMIN_EXPORT => ['Export Club Data'],
    CLUB_ADMIN_EXPORT_COMPRESSED => ['Compressed'],
    CLUB_ADMIN_EXPORT_PLAIN => ['Plain'],
    CLUB_ADMIN_GUEST_2_MEMBER => ['Invite Guest to become Member'],
    CLUB_ADMIN_GUEST_INVITE => ['Invite Guests'],
    CLUB_ADMIN_INVITE => ['Add Members'],
    CLUB_ADMIN_INVITE_LIST => ['Invites'],
    CLUB_ADMIN_MEMBER_ADD => ['Add Members'],
    CLUB_ADMIN_MEMBER_DELETE => ['Member Delete'],
    CLUB_ADMIN_TOOLS => ['Administrative Tools'],
    CLUB_ADMIN_USER_LIST => ['Club Roster'],
    CLUB_ADMIN_PUBLIC => ['Allow Public Access'],
    CLUB_ADMIN_PRIVATE => ['Close Public Access'],
    CLUB_COMMUNICATIONS_FILE_READ => ['Files'],
    CLUB_COMMUNICATIONS_FILE_RENAME => ['Rename File'],
    CLUB_COMMUNICATIONS_MESSAGE_LIST => ['Mail'],
    CLUB_COMMUNICATIONS_MAIL_LIST => ['Mail'],
    CLUB_CREATE => ['Create Club Site'],
    CLUB_HOME => ['Club Site'],
    CLUB_ADMIN_SHADOW_MEMBER_INVITE => ['Bring Members Online'],
    CLUB_LEGACY_SECURITY_RECONCILIATION => ['Identify Listed Investments'],
    CLUB_LEGACY_UPLOAD => ['Import NAIC Club Accounting(tm)'],
    CLUB_MAIL_DELETE => ['Mail Delete'],
    CLUB_MAIL_POST => ['Compose Message'],
    CLUB_MAIL_FORWARD => ['Forward Message'],
    CLUB_OPEN_BALANCE => ['Edit Opening Balances'],
    DEMO_REDIRECT => ['Demo Club'],
    GENERAL_PRIVACY => ['Safe and Private'],
    HELP => ['Help'],
    HTTP_DOCUMENT => ['Home Page'],
    LOGOUT => ['Logout'],
    MY_CLUB_SITE => ['My Club Site'],
    USER_ADMIN_PREFERENCES_EDIT => ['Change Preferences'],
    USER_AGREEMENT_TEXT => ['Terms of Service'],
    USER_HOME => ['My Site', 'MY_SITE'],

    # MAIL
    MAIL_FROM => ['From'],
    MAIL_FROM_NAME => ['From'],
    MAIL_FROM_NAME_SORT => ['From'],
    MAIL_TO => ['To'],
    MAIL_CC => ['Cc'],
    MAIL_SUBJECT => ['Subject'],
    MAIL_SUBJECT_SORT => ['Subject'],
    MAIL_DATE => ['Date'],
    MAIL_DATE_TIME => ['Date'],
    MAIL_TEXT => ['Text'],
    MAIL_ATT => ['Attach'],
    MAIL_BYTES => ['Size'],
    MAIL_DELETE => ['Delete'],
    MAIL_IS_PUBLIC => ['Public', undef, 'Mail.is_public'],
    MAIL_IS_PUBLIC_ALT => ['Message is publicly viewable'],
    MAIL_APPLY => ['Apply Changes'],

    # FILES
    FILE_NAME => ['Name'],
    FILE_NAME_SORT => ['Name'],
    FILE_OWNER => ['Owner'],
    FILE_LAST_MODIFIED => ['Last Modified'],
    FILE_MODIFIED_DATE_TIME => ['Last Modified'],
    FILE_ACTION => ['Action'],
    FILE_IS_PUBLIC => ['Public', undef, 'File.is_public'],
    FILE_IS_PUBLIC_ALT => ['File is publicly viewable'],
    FILE_SIZE => ['Size'],
    FILE_BYTES => ['Size'],
    FILE_LOCATION => ['Folder'],
    MAKE_PUBLIC => ['Publish Contents'],

    # Julie Stav
    JULIE_STAV => ['Julie Stav'],

    # Table Headings
    NAME_HEADING => ['Name', undef, 'realmowner_name_heading',
	    'last_first_middle_heading', 'realmaccount_name_heading',
	    'realmowner_display_name_heading', 'realminstrument_name_heading',
	   ],
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
    PAID_HEADING => ['Paid'],
    UNITS_HEADING => ['Units', undef, 'MemberEntry.units'],
    PERCENT_HEADING => ['Percent'],
    DESCRIPTION_HEADING => ['Description'],
    ACQUISITION_DATE_HEADING => ["Date\nAcquired", undef,
	    'RealmInstrumentEntry.acquisition_Date'],
    SELL_DATE_HEADING => ['Date Sold'],
    SALES_PRICE_HEADING => ['Sales Price'],
    COST_BASIS_HEADING => ['Cost Basis'],
    GAIN_HEADING => ['Gain/(Loss)'],
    LAST_UPDATED_HEADING => ['Last Updated'],
    BALANCE_HEADING => ['Cash Balance'],
    LAST_VALUATION_DATE_HEADING => ["Valuation\nDate"],
    PERCENT_OF_PORTFOLIO_HEADING => ["Percent of\nPortfolio"],
    SHARES_HEADING => ["Shares\nHeld", undef, 'quantity_heading',
	   'count_heading'],
    COST_PER_SHARE_HEADING => ["Cost Basis\nper Share"],
    TOTAL_COST_HEADING => ["Total\nCost Basis"],
    SHARE_PRICE_HEADING => ["Price per\nShare"],
    UNREALIZED_GAIN_HEADING => ["Unrealized\nGain/(Loss)"],
    PERCENT_OF_TOTAL_HEADING => ["Percent\nof Total"],
    CASH_ACCOUNT_HEADING => ['Cash Account'],
    REALMTRANSACTION_DATE_TIME_HEADING => ['Date'],
    REALMTRANSACTION_REMARK_HEADING => ['Remark'],
    ENTRY_AMOUNT_HEADING => ['Amount'],
    REALMINSTRUMENTENTRY_COUNT_HEADING => ['Shares'],
    RECIPIENT_HEADING => ['Recipient'],
    CLUB_COST_BASIS_HEADING => ["Club's\nCost Basis"],
    EXEC_HEADING => ['Exec.'],
    ENTRY_ENTRY_TYPE_HEADING => ['Type'],
    ENTRY_TAX_CATEGORY_HEADING => ['Tax'],
    REMARK_HEADING => ['Remark'],
    CATEGORY_HEADING => ['Category'],
    ACTION_HEADING => ['Action'],
    MEMBERENTRY_VALUATION_DATE_HEADING => ['Val. Date'],
    MEMBERENTRY_UNITS_HEADING => ['Units'],
    PAID_YTD_HEADING => ["Paid YTD"],
    UNITS_YTD_HEADING => ["Units YTD"],
    TAX_BASIS_HEADING => ["Tax Basis"],
    REALMINSTRUMENTENTRY_ACQUISITION_DATE_HEADING => ["Acquisition\nDate"],
    MARKET_VALUE_HEADING => ["Market\nValue", undef, 'value_heading',
	   'total_value_heading'],
    MEMBER_COST_BASIS_HEADING => ["Member's Adj.\nCost Basis"],
    AVERAGE_ANNUAL_RETURN_HEADING => ["Average\nAnnual Return"],
    AMOUNT_INVESTED_HEADING => ['Investments'],
    AMOUNT_RETURNED_HEADING => ['Returns'],
    SHOW_INACTIVE => ['Show All'],
    SHOW_INACTIVE_INSTRUMENTS => ['Show All Investments'],
    SHOW_INACTIVE_MEMBERS => ['Show Withdrawn Members'],
    LIST_ACTIONS_HEADING => ['Actions'],
    NAME_AND_ADDRESS => ["Name\nAddress"],
    EMAIL_AND_PHONE => ["Email\nPhone"],
    PRIVILEGES_AND_USER_ID => ["Privileges\nUser ID"],
    USER_CLUB_PRIVILEGES => ['Your Privileges'],
    USER_CLUB_HEADING => ['Club'],

    # Invite List
    REALMINVITE_EMAIL_HEADING => ['Email'],
    REALMINVITE_HONORIFIC_HEADING => ['Privileges'],
    REALMINVITE_CREATION_DATE_TIME_HEADING => ['Date'],
    INVITED_BY_HEADING => ['Invited By'],
    AUTH_CODE_HEADING => ["Authorization\nCode"],
    AUTH_CODE => ["Authorization Code"],

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
    SEARCH_STRING => ['Search'],
    SEARCH_RESULT => ['Result'],

    # Misc. Features
    NEW_HARDWARE => ['New Computers'],

    # Announcements
    ANNOUNCE_FOOL => ['Foolish bivions'],
    ANNOUNCE_EXPO => ['Investment Expo'],

    # PrevNextBar
    PREV_NEXT_BAR_PREV_LIST => ['prev'],
    PREV_NEXT_BAR_NEXT_LIST => ['next'],
    PREV_NEXT_BAR_PREV_DETAIL => ['prev'],
    PREV_NEXT_BAR_NEXT_DETAIL => ['next'],
    PREV_NEXT_BAR_THIS_LIST => ['back to list'],
    PREV_NEXT_BAR_ONLY_ONE_PAGE => ['page 1 of 1'],
    PREV_NEXT_BAR_GO_TO_PAGE => ['page'],
    PREV_NEXT_BAR_OF_PAGE => ['of %d'],
    PREV_NEXT_BAR_SPACER => [' | '],

    # Help topics
    HELP_ENABLING_COOKIES => ['Enabling Cookies in your Browser'],
    HELP_COOKIES => ['Cookies'],
    HELP_VALUATION_DATE => ['Valuation Date'],
    HELP_UNIT_VALUE => ['Unit Value'],
    HELP_ACCOUNT_TRANSACTIONS => ['Account Transactions'],
    HELP_INVESTMENT_TRANSACTIONS => ['Investment Transactions'],
    HELP_MEMBER_TRANSACTIONS => ['Member Transactions'],
    HELP_DELETING_TRANSACTIONS => ['Deleting Transactions'],
    HELP_TAX_ALLOCATION_METHODS => ['Tax Allocation Methods'],
    HELP_EXPENSES => ['Expenses'],
    HELP_FEES => ['Fees'],
    HELP_PRINTING => ['Printing'],
    HELP_FONT_SIZE => ['Font Size'],

    # Preferences
    PAGE_SIZE => ['List Size'],
    FACADE_CHILD_TYPE => ['Style'],
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

=for html <a name="unsafe_get_simple"></a>

=head2 unsafe_get_simple(any value) : string

Returns the "simple" name we use for this label.
You can use any part of the label to do the lookup.
Returns undef if label not found.

=cut

sub unsafe_get_simple {
    my($proto, $value) = @_;
    my($label) = $proto->unsafe_from_any($value);
    return defined($label) ? $label->get_short_desc : undef;
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
