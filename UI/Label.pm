# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Label;
use strict;
$Bivio::UI::Label::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Label::VERSION;

=head1 NAME

Bivio::UI::Label - a mapping of IDs to labels

=head1 SYNOPSIS

    use Bivio::UI::Label;
    Bivio::UI::Label->get_simple($value);

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::Label::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::Label> maps internal names to UI strings.  The names are
N-tuples: a primary name followed by N-1 qualifiers.  The qualifiers
are applied left to right.  The name and qualifiers may be a single
string combined with L<SEPARATOR|"SEPARATOR"> or an array_ref.

RJN: I was thinking of allowing nesting, but see no need for it now.
Better to be explicit.

=cut

=head1 CONSTANTS

=cut

=for html <a name="SEPARATOR"></a>

=head2 SEPARATOR : string

Returns separator character (#).

=cut

sub SEPARATOR {
    return '#';
}

#=IMPORTS
use Bivio::Die;
use Bivio::Type::TaxCategory;

#=VARIABLES
my(%_MAP);
# Configuration syntax (asserted by _compile()) is as follows:
#
#   * A list of tuples is an array_ref: (name1, value1), (name2, value2), ...
#   * A name can be a string or an array_ref (a list of names that match)
#   * A value can be string or a list of tuples.
#   * A list of tuples must have a default value (name is '') or
#     a single qualifier at that level.
#
# We use array_refs here, because we can then check duplicates.
#
_compile(\%_MAP, [
#TODO: Should these be dynamically looked up?
    # Common labels
    NONE => ' ',
    ['PHONE', 'Phone.phone']
        => 'Phone',
    ['TAX_ID', 'TaxId.tax_id']
        => 'Tax ID',
    ['EMAIL', 'Email.email', 'RealmInvite.email']
        => 'Email',
    ['Email.want_bulletin']
        => 'Receive monthly updates on bivio features and services.',
    ['PASSWORD', 'RealmOwner.password', 'RealmAccount.external_password']
        => 'Password',
    OLD_PASSWORD => 'Current Password',
    NEW_PASSWORD => 'New Password',
    CONFIRM_NEW_PASSWORD => 'Confirm New',
    CONFIRM_PASSWORD => 'Confirm',
    LOGIN => 'Login',
    ['SAVE_PASSWORD', 'LoginForm.save_password']
        => 'Save Password',
    SECURE_MODE => 'Secure Mode',
    NAIC_CLUB_ACCOUNTING => 'NAIC Club Accounting(tm)',

    # Address labels
    ADDRESS => 'Address',
    ['STREET1', 'Address.street1']
        => 'Street1',
    ['STREET2', 'Address.street2']
        => 'Street2',
    ['CITY', 'Address.city']
        => 'City',
    ['STATE', 'Address.state']
        => 'State',
    ['ZIP', 'Address.zip']
        => 'Zip',
    ['COUNTRY', 'Address.country', 'country_code']
        => 'Country',
    ADDRESS_COUNTRY => 'Country',
    ADDRESS_STATE => 'State',

    # Form Buttons
    ['APPLY_CHANGES_BUTTON', 'MAIL_APPLY'] => 'Apply Changes',
    CALCULATE_BUTTON => 'Calculate',
    CANCEL_BUTTON => 'Cancel',
    CHANGE_PREFERENCES_BUTTON => 'Refresh',
    CONTINUE_BUTTON => 'Continue',
    CREATE_BUTTON => 'Create',
    I_ACCEPT_BUTTON => ' I Accept ',
    I_DECLINE_BUTTON => ' I Decline ',
    LOGIN_BUTTON => 'Login',
    ['LOOKUP_BUTTON', 'symbol_lookup_button']
        => 'Symbol Lookup',
    LOOKUP_BUTTON_HEADING => 'Symbol',
    LOT_BUTTON => 'Lots',
    NEXT_BUTTON => ' Next ',
    OK_BUTTON => '  OK  ',
    REFRESH_BUTTON => 'Refresh',
    REGISTER_BUTTON => 'Register',
    SEND_BUTTON => ' Send ',
    TICKER_BUTTON => 'Ticker',
    ['UNLISTED_BUTTON', 'new_unlisted', 'new_unlisted_button']
        => 'New Unlisted',

    # Club labels
    CLUB_DISPLAY_NAME => 'Name',
    CLUB_NAME => 'Club ID',
    ['CLUB_USER_TITLE', 'RealmUser.title']
        => 'Privileges',
    ['CLUB_USER_CREATION_DATE_TIME', 'RealmUser.creation_date_time']
        => 'Joined',
    ['CLUB_START_DATE', 'Club.start_date']
        => 'Date Club Started',
    MY_DEMO_CLUB => 'My Demo Club',

    # User labels
    ['USER_DISPLAY_NAME', 'RealmOwner.display_name']
        => 'Name',
    USER_NAME => 'User ID',
    NAME_OR_EMAIL => 'User ID or Email',
    ['USER_FIRST_NAME', 'User.first_name']
        => 'First Name',
    ['USER_MIDDLE_NAME', 'User.middle_name']
        => 'Middle Name',
    ['USER_LAST_NAME', 'User.last_name']
        => 'Last Name',
    ['USER_LAST_NAME_SORT', 'User.last_name_sort']
        => 'Last Name',

    # Accounting labels
    ['TRANSACTION_DATE', 'RealmTransaction.date_time']
        => 'Transaction Date',
    ['VALUATION_DATE', 'MemberEntry.valuation_date', 'member_valuation_date']
        => 'Member Valuation Date',
    MULTIPLE_PAYMENT => 'Enter Member Payments',
    MULTIPLE_FEE => 'Enter Member Fees',
    ['AMOUNT', 'Entry.amount']
        => 'Amount',
    ['ACCOUNT', 'RealmAccount.realm_account_id', 'RealmAccountEntry.realm_account_id']
        => 'Account',
    ['ACCOUNT_INSTITUTION', 'RealmAccount.institution']
        => 'Institution',
    ['ACCOUNT_NUMBER', 'RealmAccount.account_number']
        => 'Account Number',
    ['REMARK', 'RealmTransaction.remark']
        => 'Remark',
    DEFAULT_REMARK => 'Default Remark',
    MEMBER_SPECIFIC_REMARK => 'Member Specific Remark',
    ['REALM_INSTRUMENT_NAME', 'RealmInstrument.name']
        => 'Full Name',
    ['SHARES', 'RealmInstrumentEntry.count', 'quantity']
        => 'Shares',
    COMMISSION => 'Commission',
    ADMIN_FEE => 'Service Fee',
    ['TICKER', 'Instrument.ticker_symbol', 'RealmInstrument.ticker_symbol', 'ticker_symbol', 'source_ticker_symbol']
        => 'Ticker',
    ['INSTRUMENT_TYPE', 'RealmInstrument.instrument_type']
        => 'Category',
    LOCAL_INSTRUMENTS => 'Unlisted Investments',
    LOCAL_INSTRUMENT => 'Unlisted Investment',
    ['PRICE_PER_SHARE', 'RealmInstrumentValuation.price_per_share', 'share_price']
        => 'Price/Share',
    NAME_TICKER => 'Name',
    ['FED_TAX_FREE', 'RealmInstrument.fed_tax_free']
        => 'Federal Tax Free',
    ['VALUATION_SEARCH_DATE', 'InstrumentMergerSpinoff.action_date'] => 'Date',
    IMPORT_USER_INFO => 'Import User Information',
    WANT_SSN => 'Social Security Numbers',
    WANT_PHONE => 'Telephone Numbers',
    WANT_ADDRESS => 'Addresses',
    ['PARTNER_IS_PARTNERSHIP', 'Tax1065.partner_is_partnership']
        => 'Is a member of this club also a partnership?',
    ['PARTNERSHIP_IS_PARTNER', 'Tax1065.partnership_is_partner']
        => 'Is this club a partner in another partnership?',
    ['CONSOLIDATED_AUDIT', 'Tax1065.consolidated_audit']
        => 'Is this partnership subject to the consolidated audit procedures of 6221 through 6223?',
    ['ENTITY_TYPE', 'TaxK1.entity_type']
        => 'Entity Type',
    ['PARTNER_TYPE', 'TaxK1.partner_type']
        => 'Partner Type',
    ['IRS_CENTER', 'TaxK1.irs_center']
        => 'IRS Center',
    ['FOREIGN_PARTNER', 'TaxK1.foreign_partner']
        => 'Foreign Partner',
    ['SHORT_TERM_CAPITAL_GAIN',
        Bivio::Type::TaxCategory->SHORT_TERM_CAPITAL_GAIN->get_short_desc]
        => 'Short-Term Capital Gains',
    ['MEDIUM_TERM_CAPITAL_GAIN',
        Bivio::Type::TaxCategory->MEDIUM_TERM_CAPITAL_GAIN->get_short_desc]
        => 'Medium-Term Capital Gains',
    ['LONG_TERM_CAPITAL_GAIN',
        Bivio::Type::TaxCategory->LONG_TERM_CAPITAL_GAIN->get_short_desc]
        => 'Long-Term Capital Gains',
    ['FIVE_YEAR_CAPITAL_GAIN',
        Bivio::Type::TaxCategory->FIVE_YEAR_CAPITAL_GAIN->get_short_desc]
        => 'Five Year Capital Gains',
    ['MISC_INCOME',
        Bivio::Type::TaxCategory->MISC_INCOME->get_short_desc]
        => 'Miscellaneous Income',
    TOTAL_INCOME => 'Total Income',
    ['MISC_EXPENSE',
        Bivio::Type::TaxCategory->MISC_EXPENSE->get_short_desc]
        => 'Miscellaneous Expense',
    ['FOREIGN_TAXES',
        Bivio::Type::TaxCategory->FOREIGN_TAX->get_short_desc, 'foreign_taxes_paid']
        => 'Foreign Taxes',
    ['NON_DEDUCTIBLE_EXPENSE',
        Bivio::Type::TaxCategory->NON_DEDUCTIBLE_EXPENSE->get_short_desc]
        => 'Non-Deductible Expense',
    TOTAL_EXPENSE => 'Total Expense',
    NET_PROFIT => 'Net Profit/(Loss)',
    ALLOCATION_METHOD => 'Allocation Method',
    ['TAX_FREE_INT',
        Bivio::Type::TaxCategory->FEDERAL_TAX_FREE_INTEREST->get_short_desc]
        => 'Federal Tax Free Interest',
    PAID => 'Total Paid',
    EARNINGS => 'Earnings Allocated',
    ADD_ROWS => 'Add More Rows',
    FEE => 'Fee',
    WITHDRAWAL_TYPE => 'Type',
    SELECTED => 'Selected',
    ['ACQUISITION_DATE', 'RealmInstrumentEntry.acquisition_date']
        => 'Acquisition Date',
    COST_PER_SHARE => 'Cost/Share',
    COST => 'Cost Basis',
    TRANSFER_VALUATION_DATE => 'Transfer Valuation Date',
    WITHDRAWAL_VALUE => 'Withdrawal Value',
    WITHDRAWAL_FEE => 'Withdrawal Fee',
    WITHDRAWAL_AMOUNT => 'Withdrawal Amount',
    CASH_WITHDRAWN => 'Cash',
    INSTRUMENT_FMV => "Investments' FMV",
    WITHDRAWAL_ADJUSTMENT => 'Post-Withdrawal Adjustment',
    MEMBER_TAX_BASIS => "Member's Tax Basis",
    WITHDRAWAL_ALLOCATIONS => 'Current Income Allocation',
    MEMBER_INSTRUMENT_COST_BASIS => 'Stock',
    UNIT_VALUE => 'Unit Value',
    UNITS_WITHDRAWN => 'Units Withdrawn',
    ['GENERATE', 'generate2']
        => 'Generate',
    REPORT_DATE => 'Report Date',
    REPORT_YEAR => 'Report Year',
    ['TASK_ID', 'task_id2']
        => 'Task',
    FEE_PERCENT => 'Percent Fee Type',
    MONTH => 'Month',
    PRE_WITHDRAWAL_BASIS => "Member's Basis Before Withdrawal",
    ADJUSTED_BASIS => '(A)  Adjusted basis',
    BASIS_WITHDRAWN => '(B)  Total',
    WITHDRAWAL_REALIZED_GAIN => 'Gain/(Loss) Realized on Withdrawal (B)-(A)',
    BASIS_AFTER_WITHDRAWAL => "Member's Basis After Withdrawal",
    RETURN_SINCE => 'Return Since',
    RETURN_TO => 'Return To',
    PREPARATION_DATE => 'Report Preparation Date',
    REMAINING_BASIS => 'Remaining Basis Percentage',
    INCOME_TYPE => 'Distribution Type',
    PARENT_PRICE => 'Parent Price/Share',
    CHILD_PRICE => 'Child Price/Share',
    FRACTIONAL_SHARE_CASH => 'Cash Received',
    ACQUIRING_TICKER_SYMBOL => 'Acquiring Ticker',
    PAYMENT => 'Payment',
    ADJUSTMENT => 'Adjustment',
    SOURCE_ACCOUNT_ID => 'Source Account',
    TARGET_ACCOUNT_ID => 'Target Account',
    EASY_ACTIONS => 'Shortcuts',
    INVESTMENT => 'Investment',
    ['MEMBER', 'RealmUser.user_id']  => 'Member',
    TOTAL_ASSETS => 'Total Assets',
    TOTAL_LIABILITIES => 'Total Liabilities and Capital',
    INVESTMENTS_COST => 'Investments (cost basis)',
    MEMBER_CAPITAL_ACCOUNTS => 'Member Capital Accounts (adjusted cost basis)',
    UNALLOCATED_EARNINGS => 'Unallocated Earnings - (Losses)',
    UNREALIZED_GAINS => 'Unrealized (Gains)/Losses Disbursed',
    EXPENSE => 'Expense',
    NEW_SHARES => 'New Shares',
    ['CATEGORY', 'ExpenseCategory.expense_category_id']
        => 'Category',
    ['TAX_FREE_INTEREST', 'RealmAccount.tax_free']
        => 'Tax Free Interest',
    ['ACCOUNT_NAME', 'RealmAccount.name']
        => 'Name',
    BALANCE => 'Cash Balance',
    ['ALLOCATE_EQUALLY', 'ExpenseInfo.allocate_equally']
        => 'Allocate Equally Among Members',
    'Tax1065.allocation_method' => 'Allocation Method',
    FOREIGN_INCOME_COUNTRY_HEADING => '17a. Country',
    FOREIGN_INCOME_HEADING => "17c(1). Passive\nForeign Gross Income",
    FOREIGN_TAXES_PAID_HEADING => "17f. Total Foreign\nTaxes Paid",
    SOURCE_NAME => 'Source',
    NEW_NAME => 'New Security',
    'InstrumentMergerSpinoff.action' => 'Action',
    'InstrumentMergerSpinoff.remaining_basis' => 'Remaining Basis',
    'InstrumentMergerSpinoff.new_shares_ratio' => 'New Shares Ratio',
    'InstrumentMergerSpinoff_remaining_basis_HEADING' => "Remaining\nBasis",
    'InstrumentMergerSpinoff_new_shares_ratio_HEADING' => "New Shares\nRatio",
    NEW_TICKER_SYMBOL => 'New Ticker Symbol',

    # Accounting Reports (Tasks sorted alphabetically)
    CLUB_ACCOUNTING_REPORT => 'Accounting Reports',
    CLUB_ACCOUNTING_REPORT_BALANCE_SHEET => 'Balance Sheet',
    CLUB_ACCOUNTING_REPORT_CASH_ACCOUNT_SUMMARY => [
	'' => 'Accounts',
	help_topic => 'Accounts Report',
    ],
    CLUB_ACCOUNTING_REPORT_COMPARISON_PERFORMANCE => [
	'' => 'Performance Comparison',
	help_topic => 'Performance Comparison Report',
    ],
    CLUB_ACCOUNTING_REPORT_COMPLETE_JOURNAL => 'Transaction Ledger',
    CLUB_ACCOUNTING_REPORT_INCOME_EXPENSE_STATEMENT => 'Income Statement',
    CLUB_ACCOUNTING_REPORT_INVESTMENT_PERFORMANCE => [
	'' => 'Investment Performance',
	help_topic => 'Investment Performance Report',
    ],
    CLUB_ACCOUNTING_REPORT_INVESTMENT_PERFORMANCE_DETAIL =>
    [
	'' => 'Investment Performance Detail',
	help_topic => 'Investment Performance Detail Report',
    ],
    CLUB_ACCOUNTING_REPORT_INVESTMENT_SALE => [
	'' => 'Capital Gains and Losses',
	help_topic => 'Capital Gains and Losses Report',
    ],
    CLUB_ACCOUNTING_REPORT_INVESTMENT_SUMMARY => [
	'' => 'Investments',
	help_topic => 'Investments Report',
    ],
    CLUB_ACCOUNTING_REPORT_MEMBER_ALLOCATION => [
	'' => 'Member Tax Allocations',
	help_topic => 'Member Tax Allocations Report',
    ],
    CLUB_ACCOUNTING_REPORT_MEMBER_PERFORMANCE => [
	'' => 'Member Performance',
	help_topic => 'Member Performance Report',
    ],
    CLUB_ACCOUNTING_REPORT_MEMBER_PERFORMANCE_DETAIL => [
	'' => 'Member Performance Detail',
	help_topic => 'Member Performance Detail Report',
    ],
    CLUB_ACCOUNTING_REPORT_MEMBER_STATUS => [
	'' => 'Member Status',
	help_topic => 'Member Status Report',
    ],
    CLUB_ACCOUNTING_REPORT_MEMBER_SUMMARY => [
	'' => 'Members',
	help_topic => 'Members Report',
    ],
    CLUB_ACCOUNTING_REPORT_MEMBER_WITHDRAWAL => [
	'' => 'Member Withdrawal',
	help_topic => 'Member Withdrawal Report',
    ],
    # Not really a report, but on the report page
    CLUB_ACCOUNTING_REPORT_MEMBER_WITHDRAWAL_LIST =>
	'Member Withdrawal Summary',
    CLUB_ACCOUNTING_REPORT_MISC_INCOME_AND_DEDUCTIONS =>
	'Income and Expense History',
    CLUB_ACCOUNTING_REPORT_SELF_PERFORMANCE_DETAIL => [
	'' => 'Member Performance Detail',
	help_topic => 'Member Performance Detail Report',
    ],
    CLUB_ACCOUNTING_REPORT_TRANSACTION_HISTORY => 'Transaction History',
    CLUB_ACCOUNTING_REPORT_VALUATION_STATEMENT => [
	'' => 'Valuation (NAV)',
	HELP_TOPIC => 'Valuation (NAV) Report',
    ],

    # NCA Import
    NCADATA => 'NCADATA.DAT',

    # Menu Titles
    CLUB_ADMIN => 'Administration',
    CLUB_ACCOUNTING => 'Accounting',
    CLUB_COMMUNICATIONS => 'Communications',
    USER_ADMIN => 'Administration',
    USER_CLUB => 'Clubs',

    # Page Titles
    TITLE_HOME_PAGE => 'Home',
    TITLE_SITE => 'bivio',
    REALM_CHOOSER => 'Select Site',

    # Tasks (sorted alphabetically)
    ADM_REALM_NOTICE_LIST => 'Notices',
    ADM_MERGER_SPINOFF_CREATE => 'Create New Merger/Spin-off Information',
    ADM_MERGER_SPINOFF_LIST => 'Mergers & Spin-offs',
    CLUB_ACCOUNTING_ACCOUNT_DETAIL => 'Account Detail',
    CLUB_ACCOUNTING_ACCOUNT_DIVIDEND => 'Account Dividend',
    CLUB_ACCOUNTING_ACCOUNT_EXPENSE => 'Account Expense',
    CLUB_ACCOUNTING_ACCOUNT_INCOME => 'Account Income',
    CLUB_ACCOUNTING_ACCOUNT_INTEREST => 'Account Interest',
    CLUB_ACCOUNTING_ACCOUNT_LIST => 'Account Summary',
    CLUB_ACCOUNTING_ACCOUNT_TRANSFER => 'Account Transfer',
    CLUB_ACCOUNTING_REALM_ACCOUNT_CREATE => [
	# This label isn't in use, yet.
	'' => 'Create New Account',
	HELP_TOPIC => 'Creating New Accounts',
    ],
    CLUB_ACCOUNTING_CLEAR => 'Clear Online Accounting',
    CLUB_ACCOUNTING_FEE => 'Fees',
    CLUB_ACCOUNTING_INVESTMENT_ADJUSTMENT => 'Basis Adjustment',
    CLUB_ACCOUNTING_INVESTMENT_BUY => 'Record Purchase',
    CLUB_ACCOUNTING_INVESTMENT_CHARGES_PAID => 'Charges Paid by Company',
    CLUB_ACCOUNTING_INVESTMENT_DETAIL => 'Investment Detail',
    CLUB_ACCOUNTING_INVESTMENT_INCOME => 'Investment Income',
    CLUB_ACCOUNTING_INVESTMENT_LIST => 'Investment Summary',
    CLUB_ACCOUNTING_INVESTMENT_LOT_LIST => 'Investment Lots',
    CLUB_ACCOUNTING_INVESTMENT_MERGER => 'Investment Merger',
    CLUB_ACCOUNTING_INVESTMENT_REINVEST => 'Reinvest Income',
    CLUB_ACCOUNTING_INVESTMENT_SELL => 'Record Sale',
    CLUB_ACCOUNTING_INVESTMENT_SPINOFF => 'Investment Spin-off',
    CLUB_ACCOUNTING_INVESTMENT_SPINOFF_BASIS => 'Investment Basis Calculator',
    CLUB_ACCOUNTING_INVESTMENT_SPLIT => 'Stock Split',
    CLUB_ACCOUNTING_LOCAL_INSTRUMENT => 'New Unlisted Investment',
    CLUB_ACCOUNTING_LOCAL_VALUATION_DATES => 'Change Past Valuations',
    CLUB_ACCOUNTING_LOCAL_VALUE => 'Value Unlisted Investments',
    CLUB_ACCOUNTING_MEMBER_ADJUSTMENT => 'Member Basis/Unit Adjustment',
    CLUB_ACCOUNTING_MEMBER_DETAIL => 'Member Detail',
    CLUB_ACCOUNTING_MEMBER_FEE => 'Member Fee',
    CLUB_ACCOUNTING_MEMBER_LIST => 'Member Summary',
    CLUB_ACCOUNTING_MEMBER_PAYMENT => 'Member Payment',
    CLUB_ACCOUNTING_MEMBER_WITHDRAWAL => 'Member Withdrawal',
    CLUB_ACCOUNTING_MEMBER_WITHDRAWAL_STOCK => 'Member Investment Withdrawal',
    CLUB_ACCOUNTING_PAYMENT => 'Payments',
    CLUB_ACCOUNTING_TAXES_ALLOCATIONS => 'Member Tax Allocations ',
    CLUB_ACCOUNTING_TAXES_ALLOCATION_METHOD => [
	'' => 'Allocation Method',
	help_topic => 'Tax Allocation Methods',
    ],
    CLUB_ACCOUNTING_TAXES_CHECKLIST => 'Tax Checklist',
    CLUB_ACCOUNTING_TAXES_F1065_OPTIONS => 'IRS 1065 Tax Fields',
    CLUB_ACCOUNTING_TAXES_K1_OPTIONS => 'IRS K-1 Tax Fields',
    CLUB_ACCOUNTING_TAXES_MISSING_FIELDS => 'Missing Required Fields',
    CLUB_ADMIN_CLUB_DELETE => 'Delete Club',
    CLUB_ADMIN_EC_PAYMENT_CANCELLED => 'Payment Cancelled',
    CLUB_ADMIN_EC_SUBSCRIPTIONS => 'Premium Subscriptions',
    CLUB_ADMIN_EC_SUBSCRIBE_DONE => 'Thank You!',
    CLUB_ADMIN_EC_PAYMENTS => 'Premium Payments',
    CLUB_ADMIN_EXPORT => [
	'' => 'Export Club Data',
	help_topic => 'Exporting Club Data',
    ],
    CLUB_ADMIN_EXPORT_COMPRESSED => 'Compressed',
    CLUB_ADMIN_EXPORT_PLAIN => 'Plain',
    CLUB_ADMIN_GUEST_2_MEMBER => 'Invite Guest to become Member',
    CLUB_ADMIN_GUEST_INVITE => 'Invite Guests',
    CLUB_ADMIN_INVITE => 'Add Members',
    CLUB_ADMIN_INVITE_LIST => 'Invites',
    CLUB_ADMIN_INFO => 'Club Info',
    CLUB_ADMIN_MEMBER_ADD => [
	'' => 'Add Members',
	help_topic => 'Adding Members and Guests',
    ],
    CLUB_ADMIN_MEMBER_DELETE => 'Member Delete',
    CLUB_ADMIN_MEMBER_MERGE => 'Merge Members',
    CLUB_ADMIN_PREFERENCES_EDIT => [
	'' => 'Edit Club Configuration',
	help_topic => 'Club Configuration',
    ],
    CLUB_ADMIN_TOOLS => 'Administrative Tools',
    CLUB_ADMIN_USER_LIST => 'Club Roster',
    CLUB_ADMIN_PUBLIC => [
	'' => 'Allow Public Access',
	help_topic => 'Public Access',
    ],
    CLUB_ADMIN_PRIVATE => 'Close Public Access',

    CLUB_COMMUNICATIONS_FILE_READ => 'Files',
    CLUB_COMMUNICATIONS_FILE_RENAME => 'Rename File',
    CLUB_COMMUNICATIONS_MESSAGE_LIST => 'Mail',
    CLUB_COMMUNICATIONS_MAIL_LIST => [
	'' => 'Mail',
	help_topic => 'Mail Message Board',
    ],
    CLUB_CREATE => 'Create Club Site',
    CLUB_CREATED => 'Congratulations!',
    CLUB_HOME => [
	'' => 'Club Site',
	help_topic => 'Club Home Page',
    ],
    CLUB_ADMIN_SHADOW_MEMBER_INVITE => 'Bring Members Online',
    CLUB_LEGACY_SECURITY_RECONCILIATION => 'Identify Listed Investments',
    CLUB_LEGACY_UPLOAD => [
	'' => 'Import NAIC Club Accounting(tm)',
	help_topic => 'Importing NAIC Club Accounting(tm)',
    ],
    CLUB_LEGACY_UPLOAD_INSECURE => 'Import NAIC Club Accounting(tm)',
    CLUB_LEGACY_UPLOAD_INSECURE_ACK => 'Acknowledge Insecure Club Import',
    CLUB_MAIL_DELETE => 'Mail Delete',
    CLUB_MAIL_POST => 'Compose Message',
    CLUB_MAIL_FORWARD => 'Forward Message',
    CLUB_ADMIN_MEMBER_TAKE_OFFLINE => 'Take Member Offline',
    CLUB_OPEN_BALANCE => [
	'' => 'Edit Opening Balances',
	help_topic => 'Editing Opening Balances',
    ],
    CLUB_SETUP_ACCOUNTING => 'Step 2: Setup Accounting',
    CLUB_SETUP_AGE => 'Step 3: Club History',
    CLUB_SETUP_SWITCHOVER_CHOICE => [
	'' => 'Step 4: Accounting Switchover',
	help_topic => 'Switchover Date',
    ],
    DEMO_REDIRECT => 'Demo Club',
    GENERAL_PRIVACY => 'Safe and Private',
    HELP => 'Help',
    HTTP_DOCUMENT => 'Home Page',
    LOGOUT => 'Logout',
    MEMBER_OFFLINE_CONFIRMATION => 'Offline Confirmation',
    MY_CLUB_SITE => 'My Club Site',
    ['USER_ADMIN_PREFERENCES_EDIT', 'USER_ADMIN_PREFERENCES_EDIT_WITH_CONTEXT']
        => 'Change User Preferences',
    PASSWORD_FORGOTTEN => 'Forgot Your Password?',
    PASSWORD_FORGOTTEN_CONFIRMATION => 'Password Assistance',
    USER_AGREEMENT_TEXT => 'Terms of Service',
    ['USER_HOME', 'MY_SITE']
        => 'My Site',

    # MAIL
    MAIL_FROM => 'From',
    MAIL_FROM_NAME => 'From',
    MAIL_FROM_NAME_SORT => 'From',
    MAIL_TO => 'To',
    MAIL_CC => 'Cc',
    MAIL_SUBJECT => 'Subject',
    MAIL_SUBJECT_SORT => 'Subject',
    MAIL_DATE => 'Date',
    MAIL_DATE_TIME => 'Date',
    MAIL_TEXT => 'Text',
    MAIL_ATT => 'Attach',
    ['MAIL_BYTES', 'size'] => 'Size',
    ['MAIL_DELETE', 'delete'] => 'Delete',
    ['FILE_IS_PUBLIC', 'File.is_public', 'MAIL_IS_PUBLIC', 'Mail.is_public']
        => 'Public',
    MAIL_IS_PUBLIC_ALT => 'Message is publicly viewable',

    # FILES
    FILE_NAME => 'Name',
    FILE_NAME_SORT => 'Name',
    FILE_OWNER => 'Owner',
    FILE_LAST_MODIFIED => 'Last Modified',
    FILE_MODIFIED_DATE_TIME => 'Last Modified',
    FILE_ACTION => 'Action',
    FILE_SIZE => 'Size',
    FILE_BYTES => 'Size',
    FILE_LOCATION => 'Folder',
    FILE_IS_PUBLIC_ALT => 'File is publicly viewable',
    MAKE_PUBLIC => 'Publish Contents',

    # Table Headings
    ['NAME_HEADING', 'realmowner_name_heading', 'last_first_middle_heading', 'realmaccount_name_heading', 'realmowner_display_name_heading', 'realminstrument_name_heading']
        => [['', 'table_heading'] => 'Name'],
    ['DIVIDEND_HEADING', 'dividend'] => 'Dividend',
    ['INTEREST_HEADING', 'interest'] => 'Interest',
    TAX_FREE_INT_HEADING => "Tax Free\nInterest",
    STCG_HEADING => "Short-Term\nCapital Gains",
    MTCG_HEADING => "Medium-Term\nCapital Gains",
    LTCG_HEADING => "Long-Term\nCapital Gains",
    '5YCG_HEADING' => "Five Year\nCapital Gains",
    FOREIGN_TAX_HEADING => "Foreign\nTax",
    MISC_INCOME_HEADING => "Misc.\nIncome",
    MISC_EXPENSE_HEADING => "Misc.\nExpense",
    NET_PROFIT_HEADING => "Net\nProfit",
    PAID_HEADING => 'Paid',
    ['UNITS_HEADING', 'MemberEntry.units', 'units']
        => 'Units',
    PERCENT_HEADING => 'Percent',
    DESCRIPTION_HEADING => 'Description',
    SELL_DATE_HEADING => 'Date Sold',
    SALES_PRICE_HEADING => 'Sales Price',
    COST_BASIS_HEADING => 'Cost Basis',
    GAIN_HEADING => 'Gain/(Loss)',
    LAST_UPDATED_HEADING => 'Last Updated',
    BALANCE_HEADING => 'Cash Balance',
    LAST_VALUATION_DATE_HEADING => "Valuation\nDate",
    PERCENT_OF_PORTFOLIO_HEADING => "Percent of\nPortfolio",
    ['SHARES_HEADING', 'quantity_heading', 'count_heading']
        => 'Shares
Held',
    COST_PER_SHARE_HEADING => "Cost Basis\nper Share",
    TOTAL_COST_HEADING => "Total\nCost Basis",
    SHARE_PRICE_HEADING => "Price per\nShare",
    UNREALIZED_GAIN_HEADING => "Unrealized\nGain/(Loss)",
    PERCENT_OF_TOTAL_HEADING => "Percent\nof Total",
    CASH_ACCOUNT_HEADING => 'Cash Account',
    REALMTRANSACTION_DATE_TIME_HEADING => 'Date',
    REALMTRANSACTION_REMARK_HEADING => 'Remark',
    ENTRY_AMOUNT_HEADING => 'Amount',
    REALMINSTRUMENTENTRY_COUNT_HEADING => 'Shares',
    RECIPIENT_HEADING => 'Recipient',
    CLUB_COST_BASIS_HEADING => "Club's\nCost Basis",
    EXEC_HEADING => 'Exec.',
    ENTRY_ENTRY_TYPE_HEADING => 'Type',
    ENTRY_TAX_CATEGORY_HEADING => 'Tax',
    REMARK_HEADING => 'Remark',
    CATEGORY_HEADING => 'Category',
    ACTION_HEADING => 'Action',
    MEMBERENTRY_VALUATION_DATE_HEADING => 'Val. Date',
    MEMBERENTRY_UNITS_HEADING => 'Units',
    PAID_SINCE_HEADING => "Paid Since\n",
    UNITS_SINCE_HEADING => "Units Since\n",
    TAX_BASIS_HEADING => 'Tax Basis',
    REALMINSTRUMENTENTRY_ACQUISITION_DATE_HEADING => "Acquisition\nDate",
    ['MARKET_VALUE_HEADING', 'value_heading', 'total_value_heading']
        => 'Market
Value',
    MEMBER_COST_BASIS_HEADING => "Member's Adj.\nCost Basis",
    AVERAGE_ANNUAL_RETURN_HEADING => "Annualized Internal\nRate of Return",
    irr_wait_period => 'A.I.R.R. Wait Period',
    AMOUNT_INVESTED_HEADING => 'Investments',
    AMOUNT_RETURNED_HEADING => 'Returns',
    SHOW_INACTIVE => 'Show All',
    SHOW_INACTIVE_INSTRUMENTS => 'Show Inactive Investments',
    SHOW_INACTIVE_MEMBERS => 'Show Withdrawn Members',
    SHOW_INACTIVE_ACCOUNTS => 'Show Inactive Accounts',
    LIST_ACTIONS_HEADING => 'Actions',
    NAME_AND_ADDRESS => "Name\nAddress",
    EMAIL_AND_PHONE => "Email\nPhone",
    PRIVILEGES_AND_USER_ID => "Privileges\nUser ID",
    USER_CLUB_PRIVILEGES => 'Your Privileges',
    USER_CLUB_HEADING => 'Club',
    INVESTMENT_INCOME_HEADING => "Investment\nIncome",
    INVESTMENT_SALE_GAIN_HEADING => "Investment\nSale Gain",
    ['CASH_DR_HEADING', 'cash'] => 'Cash',
    INSTRUMENT_DR_HEADING => 'Investment',
    MEMBER_DR_HEADING => 'Member',
    DIVIDEND_INTEREST_DR_HEADING => "Dividend\nand Interest",
    MISC_INCOME_DR_HEADING => "Misc.\nIncome",
    SALE_GAIN_DR_HEADING => "Investment\nSale Gain",
    UNREALIZED_GAIN_DR_HEADING => "Unrealized\nGain",
    FILTRUM_TOP_HOLDINGS_INSTRUMENT_NAME => 'Top Club Holdings',
    PERCENT_REALMS => "% Clubs\nWhich Own",
    STOCK_WITHDRAWAL_VALUE_HEADING => "Stock\nWithdrawal\nValue",
    NON_DEDUCTIBLE_EXPENSE_HEADING => "Non-Deductible\nExpense",
    EARNINGS_HEADING => "Earnings\nAllocated",
    'RealmOwner.realm_type' => [table_heading => 'Realm Type'],
    'RealmNotice.creation_date_time' => [table_heading => 'Date'],
    'RealmNotice.at_least_role' => [table_heading => 'At Least Role'],
    'RealmNotice.realm_notice_type' => [table_heading => 'Notice Type'],
    'template_as_string' => [table_heading => 'Parameters'],
    ad_hoc_text => 'Message (no html)',
    email_id_or_name => 'Email, Id, or Name',

    # Page headings
    MAIL_LIST_PAGE_HEADING => 'Mail Message Board',
    MAIL_DETAIL_PAGE_HEADING => 'Mail Message',
    SEARCH_LIST_PAGE_HEADING => 'Search Results',
    TO_MODIFY_CLICK_ON_FIELD => 'To modify, click on a field name',
    EC_SUBSCRIPTION_PAGE_HEADING => 'Subscriptions',
    EC_PAYMENT_PAGE_HEADING => 'Payments',

    # Invite List
    REALMINVITE_EMAIL_HEADING => 'Email',
    REALMINVITE_HONORIFIC_HEADING => 'Privileges',
    REALMINVITE_CREATION_DATE_TIME_HEADING => 'Date',
    INVITED_BY_HEADING => 'Invited By',
    AUTH_CODE_HEADING => "Authorization\nCode",
    AUTH_CODE => 'Authorization Code',

    # HTML Tax attachment label headings
    TAX_DESCRIPTION_OF_PROPERTY_1_HEADING => '1 (a) Description of property',
    TAX_DESCRIPTION_OF_PROPERTY_6_HEADING => '6 (a) Description of property',
    TAX_ACQUISITION_DATE_HEADING => '(b) Date acquired',
    TAX_SELL_DATE_HEADING => '(c) Date sold',
    TAX_SALES_PRICE_HEADING => '(d) Sales price',
    TAX_COST_BASIS_HEADING => '(e) Cost or other basis',
    TAX_GAIN_HEADING => '(f) Gain or (loss)',

    # Form Fields
    INVITE_MESSAGE => 'Message',
    CREATE_USER_DISPLAY_NAME_IN_TEXT => 'Describe yourself',
    CREATE_USER_DISPLAY_NAME => 'Your Name',
    CREATE_USER_NAME_IN_TEXT => 'Pick your own User ID and Password',
    SECURE_MODE_LINK => 'Switch to secure mode',
    AccountSyncForm => [
	accept_agreement => <<'EOF',
I agree with the
<{link_static_site('AccountSync Amendment', 'hm/account-access', 0)}>
to the site_name()
<{link_static_site('Terms of Service', 'hm/user', 0)}>.
EOF
    ],
    RealmAccountForm => [
	edit => 'Change Account Information',
	new => 'New Account Information',
	'RealmAccount.institution' => 'Brokerage',
	'RealmAccount.account_number' => 'Brokerage Login',
	'RealmAccount.external_password' => 'Brokerage Password',
    ],

    # Announcements
    ANNOUNCE_ZACKS => 'Zacks Research',

    # PrevNextBar
    PREV_NEXT_BAR_PREV_LIST => 'prev',
    PREV_NEXT_BAR_NEXT_LIST => 'next',
    PREV_NEXT_BAR_PREV_DETAIL => 'prev',
    PREV_NEXT_BAR_NEXT_DETAIL => 'next',
    PREV_NEXT_BAR_THIS_LIST => 'back to list',
    PREV_NEXT_BAR_ONLY_ONE_PAGE => 'page 1 of 1',
    PREV_NEXT_BAR_GO_TO_PAGE => 'page',
    PREV_NEXT_BAR_OF_PAGE => 'of %d',
    PREV_NEXT_BAR_SPACER => ' | ',

    # Help topics
    HELP_ACCOUNT_TRANSACTIONS => 'Account Transactions',
    HELP_CHANGING_PRIVILEGES => 'Changing Privileges',
    HELP_COOKIES => 'Cookies',
    HELP_DELETING_TRANSACTIONS => 'Deleting Transactions',
    HELP_EDITING_TRANSACTIONS => 'Editing Transactions',
    HELP_ENABLING_COOKIES => 'Enabling Cookies in your Browser',
    HELP_EXPENSES => 'Expenses',
    HELP_EXPENSE_ALLOCATION_METHODS => 'Expense Allocation Methods',
    HELP_FONT_SIZE => 'Font Size',
    HELP_INVESTMENT_TRANSACTIONS => 'Investment Transactions',
    HELP_MEMBER_TRANSACTIONS => 'Member Transactions',
    HELP_TAKING_OFFLINE => 'Taking Members Offline',
    HELP_PRICE_DATABASE => 'Price Database',
    HELP_PRINTING => 'Printing',
    HELP_PRIVILEGES => 'Privileges',
    HELP_PROBLEMS_IMPORTING_NCA =>
        'Problems Importing NAIC Club Accounting(tm)',
    HELP_SECURE_DATA => 'Secure Data Fields',
    HELP_SUSPENSE_ACCOUNT => 'Suspense Account',
    HELP_SWITCHOVER_DATE => 'Switchover Date',
    HELP_TAX_ID => 'Tax ID (EIN)',
    HELP_VALUATION_DATE => 'Valuation Date',

    # Help links
    WHATS_THIS => "[what's this?]",
    LEARN_MORE => '[learn more]',

    # Preferences
    PAGE_SIZE => 'List Size',
    FACADE_CHILD_TYPE => 'Style',
    TEXTAREA_WRAP_LINES => 'Wrap Lines',

    # page subtopics
    OVERVIEW => 'Overview',
    INVESTMENTS => 'Investments',
    ACCOUNTS => 'Accounts',
    MEMBERS => 'Members',
    REPORTS => 'Reports',
    TAXES => 'Taxes',
    INFORMATION => 'Information',
    INVITES => 'Invites',
    ROSTER => 'Roster',
    MAIL => 'Mail',
    PROFILE => 'Profile',
    PREFERENCES => 'Preferences',

    # Image alt tags
    ['LOGOUT_OFF_ALT', 'LOGOUT_R_OFF_ALT']
        => 'Sign off from bivio',
    ['LOGIN_OFF_ALT', 'LOGIN_SQUARE_OFF_ALT', 'LOGIN_R_OFF_ALT']
        => 'Sign on to bivio',
    HELP_OFF_ALT => 'Get help using bivio',
    REGISTER_R_OFF_ALT => 'Become a bivio user',
    BIVIO_POWER_ALT => 'Powered by bivio',
    services => [
	['', 'image_alt'] => 'Club Accounting - Premium Support - AccountSync'
	             .' - AccountKeeper - Professional Funds',
    ],

    # Search
    ['SEARCH_STRING', 'SEARCH_BUTTON']
        => 'Search',
    SEARCH_RESULT => 'Result',
    SCORE_PERCENT => 'Score',
    ['DATE_TIME', 'date'] => 'Date',

    # e-commerce
    ECPAYMENT_REALM => 'Club',
    ECPAYMENT_USER => 'Paid By',
    ECPAYMENT_CREATION_DATE_TIME => 'Entered On',
    ECPAYMENT_PAYMENT_TYPE => 'Paid For',
    ECPAYMENT_PROCESSOR_TRANSACTION_NUMBER => 'Transaction #',
    ECPAYMENT_PROCESSED_DATE_TIME => 'Processed On',
    ECPAYMENT_PROCESSOR_RESPONSE => 'Processor Response',
    ECPAYMENT_STATUS => 'Status',
    'ECPayment.amount' => 'Amount',
    'ECPayment.method' => 'Method',
    'ECPayment.description' => 'Description',
    'ECPayment.remark' => 'Remark',
    'ECPayment.credit_card_name' => 'Name on Card',
    'ECPayment.credit_card_zip' => "Card Owner's Zip Code",
    'ECPayment.credit_card_number' => 'Credit Card Number',
    'ECPayment.credit_card_expiration_date' => 'Card Expiration Date',
    ECPAYMENT_ACTION => 'Actions',
    ECSUBSCRIPTION_ACTION => 'Actions',
    ECSUBSCRIPTION_SUBSCRIPTION_TYPE => 'Service Name',
    ECSUBSCRIPTION_START_DATE => 'Started on',
    ECSUBSCRIPTION_END_DATE => 'Ends On',
    ECSUBSCRIPTION_RENEWAL_METHOD => 'Next Renewal Method',
    ECSUBSCRIPTION_RENEWAL_PERIOD => 'Renewal Period',
    EC_TYPE => 'Subscriptions',
    EC_PRICELIST => 'Subscription Pricing',
    CARD_TYPE => 'Type of Credit Card',
    alternate_price => 'Alternate Amount (overrides)',
    description_and_remark => "Description\nRemark",
#TODO: Are these used?
]);

=head1 METHODS

=cut

=for html <a name="get_form_field"></a>

=head2 static get_form_field(string form_class, string field) : string

Looks up the form field label.  Handles backwards compatibility issues.

=cut

sub get_form_field {
    my($proto, $form_class, $field) = @_;
    # We allow you to specify the form_class, then field name
    my($res) = $proto->unsafe_get_exactly(
	    $form_class->simple_package_name, $field);
    return defined($res) ? $res : $proto->get_simple($field);
}

=for html <a name="get_simple"></a>

=head2 get_simple(string name) : string

=head2 get_simple(string name, string qualifier, ...) : string

Returns the "simple" name we use for this label.  Can be followed
by any number of qualifiers.  The qualifiers are applied left to right.
If a qualifier isn't found, the default ('') will be used.

Dies if label is undefined.

=cut

sub get_simple {
    my($res) = shift->unsafe_get_simple(@_);
    return $res if defined($res);
    # Pass as a ref copy, so doesn't modify values on the stack
    Bivio::Die->die([@_], ': unknown label');
    # DOES NOT RETURN
}

=for html <a name="get_widget_value"></a>

=head2 static get_widget_value(string name, ...) : string

Same as L<get_simple|"get_simple">.

=cut

sub get_widget_value {
    return shift->get_simple(@_);
}

=for html <a name="unsafe_get_exactly"></a>

=head2 unsafe_get_exactly(string name, string qualifier, ...) : string

All the qualifiers much match exactly and evaluate to a label.  Defaults are
not used.

Returns C<undef> in label undefined.

=cut

sub unsafe_get_exactly {
    my(undef, @qualifier) = @_;
    my($res) = \%_MAP;
    foreach my $q (map {lc($_)} @qualifier) {
	return undef unless ref($res);
	$res = $res->{$q};
    }
    return ref($res) ? undef : $res;
}

=for html <a name="unsafe_get_simple"></a>

=head2 unsafe_get_simple(string name) : string

=head2 unsafe_get_simple(string name, string qualifier, ...) : string

Same as L<get_simple|"get_simple">.

Returns C<undef> in label undefined.

=cut

sub unsafe_get_simple {
    my(undef, $name, @qualifier) = @_;
    my($res) = $_MAP{lc($name)};
    foreach my $q (map {lc($_)} @qualifier) {
	return $res unless ref($res);
	# If a default is missing, it's undef.
	$res = defined($res->{$q}) ? $res->{$q} : $res->{''};
    }

    # Return the default for this level or the string if it isn't a ref
    return ref($res) ? $res->{''} : $res;
}

#=PRIVATE METHODS

# _compile(hash_ref map, array_ref cfg)
#
# Creates fully expanded map.  We use an array_ref so we can fully
# detect duplicates.  Returns $map.
#
sub _compile {
    my($map, $cfg) = @_;
    while (@$cfg) {
	_map($map, shift(@$cfg), shift(@$cfg));
    }
    return $map;
}

# _map(hash_ref map, any name, any value)
#
# Enters a value in _map.  Recurses if necessary.  $value may be
# a name qualifier.
#
sub _map {
    my($map, $name, $value) = @_;
    if (ref($value)) {
	Bivio::Die->die($name, '=>', $value, ': expecting an array_ref')
		    unless ref($value) eq 'ARRAY';
	# Explode the map
	$value = _compile({}, $value);
	($value->{''}) = values(%$value) if int(values(%$value)) == 1;
	# If a default is missing, that's ok
    }
    $name = [$name] unless ref($name);
    Bivio::Die->die($name, '=>', $value, ': expecting an array_ref')
		unless ref($name) eq 'ARRAY';
    foreach my $n (@$name) {
	Bivio::Die->die($n, '=>', $value, ': not expecting a ref')
		    if ref($n);
	Bivio::Die->die($n, '=>', $value, ': may not evaluate to false')
		    unless $value;
	$map->{lc($n)} = $value;
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
