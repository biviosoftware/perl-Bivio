# Copyright (c) 1999,2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::TypeError;
use strict;
$Bivio::TypeError::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::TypeError::VERSION;

=head1 NAME

Bivio::TypeError - enum of errors in converting values

=head1 SYNOPSIS

    use Bivio::TypeError;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::TypeError::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::TypeError> is a list of problems converting types.

=over 4

=item UNKNOWN

=item INTEGER

expecting a number without a decimal point

=item NUMBER_RANGE

number outside of expected range

=item NAME

name is not valid

=item DATE_TIME

date time must be number of seconds since Jan 1, 1970

=item DATE

invalid date format, must be mm/dd/yyyy

=item TIME

invalid time format, must be hh:mm, hh:mm a, hh:mm:ss p

=item NUMBER

expecting a number

=item YEAR_RANGE

year outside of valid range (1800 to 2199)

=item EXISTS

already exists

=item MONTH

invalid month

=item DAY_OF_MONTH

invalid day for this month

=item HOUR

invalid hour

=item MINUTE

invalid minute

=item SECOND

invalid second

=item NULL

field may not be empty

=item CONFIRM_PASSWORD

password and confirm password fields do not match

=item COUNTRY

country must be exactly two letters

=item PASSWORD

invalid password; must be at least six characters

=item REALM_NAME

The name you create must begin with a letter and only contain
letters, numbers, and underscores, and be at least
three characters long. Once created, you will be able to
send mail to thename@bivio.com.

=item GREATER_THAN_ZERO

must be greater than zero

=item ENUM

invalid enumerated type literal

=item NOT_FOUND

not found

=item NOT_NEGATIVE

can not be negative

=item TOO_LONG

field is too long; there may be a problem with your browser

=item YEAR_DIGITS

four digit year required (mm/dd/yyyy)

=item PASSWORD_MISMATCH

invalid password

=item LOGIN_TIMEOUT

your login session timed out, please re-enter your password

=item HASH

invalid hash value; corrupt input

=item MUST_LOGIN

your must login to access this link or command

=item STATE

state must be exactly two letters

=item MGFS_RATIO

invalid ratio

=item EMAIL

invalid email address; should be of the form mary@aol.com

=item EMAIL_DOMAIN_LITERAL

email addresses with domain literals [w.x.y.z] are not acceptable

=item EMAIL_UNQUALIFIED

email does not contain a @domain.com

=item PHONE

invalid phone number

=item DEMO_CLUB_SUFFIX

name may not end in _demo_club

=item UNSPECIFIED

field may not be unspecified

=item ALREADY_INVITED

an invitation was already extended to this person

=item CLUB_USER_ROLE

can only be Guest, Member, Accountant, or Administrator

=item LAST_CLUB_ADMIN

there must be at least one Administrator in a club

=item INVALID_SUM

shares sold doesn't match sum

=item GREATER_THAN_QUANTITY

shares sold is greater than the lot quantity

=item SHARES_SOLD_EXCEEDS_OWNED

shares sold exceeds shares owned

=item MISSING_DISTRIBUTION_AMOUNT

enter at least one distribution amount

=item TEXT_TOO_LONG

input is too long.  Maximum size is 500 characters.

=item INVALID_ACCOUNTING_REPORT

invalid accounting report selected

=item ANY

data corrupted

=item ANY_EVAL

data corrupted during processing

=item SECRET

unable to decode data

=item NO_SHARES_OWNED

no shares owned on the date specified

=item INVALID_SPLIT_SHARES

new shares can't equal old shares

=item REALM_INVITE_STATE

B<No text is not to be displayed to the user.
This error is only internally.>

=item FIRST_NAME_LENGTH

first name is too long

=item MIDDLE_NAME_LENGTH

middle name is too long

=item LAST_NAME_LENGTH

last name is too long

=item EMAIL_LOOP

email address loops back to itself.  Must not be the same as your
login name.

=item INVALID_EXPORT_FILE_FORMAT

invalid file format for export file chosen

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    UNKNOWN => [
	0,
    ],
    INTEGER => [
	1,
	undef,
	'expecting a number without a decimal point',
    ],
    NUMBER_RANGE => [
	2,
	undef,
	'number outside of expected range',
    ],
    NAME => [
	3,
	undef,
	'name is not valid',
    ],
    DATE_TIME => [
	4,
	undef,
	'date time must be number of seconds since Jan 1, 1970',
    ],
    DATE => [
	5,
	undef,
	'invalid date format, must be mm/dd/yyyy',
    ],
    TIME => [
	6,
	undef,
	'invalid time format, must be hh:mm, hh:mm a, hh:mm:ss p',
    ],
    NUMBER => [
	7,
	undef,
	'expecting a number',
    ],
    YEAR_RANGE => [
	8,
	undef,
	'year outside of valid range (1800 to 2199)',
    ],
    EXISTS => [
	9,
	undef,
	'already exists',
    ],
    MONTH => [
	10,
	undef,
	'invalid month',
    ],
    DAY_OF_MONTH => [
	11,
	undef,
	'invalid day for this month',
    ],
    HOUR => [
	12,
	undef,
	'invalid hour',
    ],
    MINUTE => [
	13,
	undef,
	'invalid minute',
    ],
    SECOND => [
	14,
	undef,
	'invalid second',
    ],
    NULL => [
	15,
	undef,
	'field may not be empty',
    ],
    CONFIRM_PASSWORD => [
	16,
	undef,
	'password and confirm password fields do not match',
    ],
    COUNTRY => [
	17,
	undef,
	'country must be exactly two letters',
    ],
    PASSWORD => [
	18,
	undef,
	'invalid password; must be at least SIX characters',
    ],
    REALM_NAME => [
	19,
	undef,
	'The name you create must begin with a letter and only contain'
	.' letters, numbers, and underscores, and be at least'
	.' three characters long. Once created, you will be able to'
	.' send mail to thename@bivio.com.',
    ],
    GREATER_THAN_ZERO => [
	20,
	undef,
	'must be greater than zero',
    ],
    ENUM => [
	21,
	undef,
	'invalid enumerated type literal',
    ],
    NOT_FOUND => [
	22,
	undef,
	'not found',
    ],
    NOT_NEGATIVE => [
	23,
	undef,
	'can not be negative',
    ],
    TOO_LONG => [
	24,
	undef,
	'field is too long; there may be a problem with your browser',
    ],
    YEAR_DIGITS => [
	25,
	undef,
	'four digit year required (mm/dd/yyyy)',
    ],
    PASSWORD_MISMATCH => [
	26,
	undef,
	'invalid password',
    ],
    LOGIN_TIMEOUT => [
	27,
	undef,
	'your login session timed out, please re-enter your password',
    ],
    HASH => [
	28,
	undef,
	'invalid hash value; corrupt input',
    ],
    MUST_LOGIN => [
	29,
	undef,
	'your must login to access this link or command',
    ],
    STATE => [
	30,
	undef,
	'state must be exactly two letters',
    ],
    MGFS_RATIO => [
	31,
	undef,
	'invalid ratio',
    ],
    EMAIL => [
	32,
	undef,
	'invalid email address; should be of the form mary@aol.com',
    ],
    EMAIL_DOMAIN_LITERAL => [
	33,
	undef,
	'email addresses with domain literals [w.x.y.z] are not acceptable',
    ],
    EMAIL_UNQUALIFIED => [
	34,
	undef,
	'email does not contain a @domain.com',
    ],
    PHONE => [
	35,
	undef,
	'invalid phone number',
    ],
    DEMO_CLUB_SUFFIX => [
	36,
	undef,
	'name may not end in _demo_club',
    ],
    UNSPECIFIED => [
	37,
	undef,
	'field may not be unspecified',
    ],
    ALREADY_INVITED => [
	38,
	undef,
	'an invitation was already extended to this person',
    ],
    CLUB_USER_ROLE => [
	39,
	undef,
	'can only be Guest, Member, Accountant, or Administrator',
    ],
    LAST_CLUB_ADMIN => [
	40,
	undef,
	'there must be at least one Administrator, President, or'
	.' Vice President in a club',
    ],
    INVALID_SUM => [
	41,
	undef,
	'shares sold doesn\'t match sum',
    ],
    GREATER_THAN_QUANTITY => [
	42,
	undef,
	'shares sold is greater than the lot quantity',
    ],
    SHARES_SOLD_EXCEEDS_OWNED => [
	43,
	undef,
	'shares sold exceeds shares owned',
    ],
    MISSING_DISTRIBUTION_AMOUNT => [
	44,
	undef,
	'enter at least one distribution amount',
    ],
    TEXT_TOO_LONG => [
	45,
	undef,
	'input is too long.  Maximum size is 500 characters.',
    ],
    INVALID_ACCOUNTING_REPORT => [
	46,
	undef,
#TODO: This can only happen if someone corrupted the form
	'invalid accounting report selected',
    ],
    ANY => [
	47,
	undef,
	'data corrupted',
    ],
    ANY_EVAL => [
	48,
	undef,
	'data corrupted during processing',
    ],
    SECRET => [
	49,
	undef,
	'unable to decode data',
    ],
    NO_SHARES_OWNED => [
	50,
	undef,
	'no shares owned on the date specified',
    ],
    INVALID_SPLIT_SHARES => [
	51,
	undef,
	'new shares can\'t equal old shares',
    ],
    REALM_INVITE_STATE => [
	52,
	undef,
	# This text is not to be displayed to the user.
	# This error is only internally.
	'',
    ],
    FIRST_NAME_LENGTH => [
	53,
	undef,
	'first name is too long',
    ],
    MIDDLE_NAME_LENGTH => [
	54,
	undef,
	'middle name is too long',
    ],
    LAST_NAME_LENGTH => [
	55,
	undef,
	'last name is too long',
    ],
    STOCK_WITHDRAWAL_NOT_SUPPORTED => [
	56,
	undef,
	'stock withdrawals are not yet supported',
    ],
    EMAIL_LOOP => [
	57,
	undef,
	'email address loops back to itself; must not be the same as your login name',
    ],
    REFERENTIAL_CONSTRAINT => [
	58,
	undef,
	'cannot delete the directory, it is not empty',
    ],
    FORM_DATA_MULTIPART_MIXED => [
	59,
	undef,
	'only one file may be uploaded at a time',
    ],
    PRIMARY_ID => [
	60,
	undef,
	'invalid URL, query string is invalid',
    ],
    EMPTY => [
	61,
	undef,
	'file cannot be empty',
    ],
    FILE_FIELD => [
	62,
	undef,
	'your browser has not submitted the file correctly; please try again',
    ],
    FILE_FIELD_RESET_FOR_SECURITY => [
	63,
	undef,
	# Real message in FormErrors.  Have one here just in case.
	'your browser reset this field for security reasons',
    ],
    SOURCE_NOT_EQUAL_TARGET => [
	64,
	undef,
	'source account and target account must be different',
    ],
    FED_TAX_ID => [
	65,
	undef,
	'invalid federal tax identifier must contain exactly 9 digits',
    ],
    NO_AMOUNTS => [
	66,
	undef,
	'you must specify at least one Amount',
    ],
    INVALID_EXPORT_FILE => [
	67,
	undef,
	'import unsuccessful, the file has been sent to support@bivio.com for analysis',
    ],
    INCORRECT_EXPORT_FILE_NAME => [
	68,
	undef,
	'the export file name must be NCADATA.DAT',
    ],
    IMPORT_IN_PROGRESS => [
	69,
	undef,
	'an import for you club is already in progress',
    ],
    MEMBER_ALREADY_MERGED => [
	70,
	undef,
	'this member has already been reconciled with existing data',
    ],
    NO_VALUATION_FOR_DATE => [
	71,
	undef,
	# Real message in FormErrors.  Have one here just in case.
	'no valuation for this date',
    ],
    TICKER_NOT_UNIQUE => [
	72,
	undef,
	'this value clashes with a ticker symbol in the bivio database',
    ],
    VALUATION_DATE_EXCEED_TRANSACTION_DATE => [
	73,
	undef,
	'the valuation date may not exceed the transaction date',
    ],
    NAME_LIKE_FUND => [
	74,
	undef,
	'please enter your name, not your club\'s name',
    ],
    INVALID => [
        75,
        undef,
        'value is invalid',
    ],
    MISSING_FIRST_LAST_MIDDLE => [
        76,
        undef,
        'You must specify at least one of First, Middle, or Last Names',
    ],
    FILE_NAME => [
	77,
	undef,
	'File names may not contain \\, /, :, *, ?, ", <, >, or |.  They may not be equal to "." or "..". or contain control characters or tabs.',
    ],
    TOO_MANY_INSTRUMENTS_BUY => [
	78,
	undef,
	'More than one club investment has that ticker, first select the investment from the Investment Summary, then select Bought',
    ],
    TOO_MANY_INSTRUMENTS_OPEN_BALANCE => [
	79,
	undef,
	'This action can not be performed because more than one club investment has that ticker',
    ],
    INVALID_OPENING_BALANCE_DATE => [
	80,
	undef,
	'For tax reasons, the date may not be beyond the start of this fiscal year',
    ],
    INVALID_PARTNERSHIP_TYPE => [
	81,
	undef,
	'A general partnership can only be made up of general partners. One or more of the current partners are not general partners',
    ],
    INVALID_PARTNER_TYPE => [
	82,
	undef,
	'The club is currently a general partnership, members may only be a general partner',
    ],
    INVALID_INSTRUMENT_OPENING_BALANCE_DATE => [
	83,
	undef,
	'The acquisition date may not be greater than the accounting switch-over date',
    ],
    UNEXPECTED_FLOPPY_EXPORT_EOF => [
	84,
	undef,
	'Import unsuccessful, the data file was truncated. Perhaps the A: drive ran out of space when exporting?',
    ],
    WITHDRAWAL_GREATER_THAN_VALUE => [
	85,
	undef,
	"The withdrawal may not be greater than the member's current value"
    ],
    CURRENT_USER_FULL_WITHDRAWAL => [
	86,
	undef,
	"You may not perform a full withdrawal on yourself. Another accountant in the club must perform this task.",
    ],
    CURRENT_USER_DELETE => [
	87,
	undef,
	"You may not remove yourself from the club. Another administrator in the club must perform this task.",
    ],
    DELETE_WITHDRAWN_USER => [
	88,
	undef,
	"A withdrawn member may not be removed from the club.",
    ],
    ACCOUNTING_IMPORT_IN_FILES => [
	89,
	undef,
	"Use the Accounting Import function to import.",
    ],
    INVALID_EXPORT_FILE_FORMAT => [
	90,
	undef,
	"invalid export file format selected",
    ],
    SHARES_SELECTED_EXCEEDS_OWNED => [
	91,
	undef,
	'shares selected exceeds shares owned',
    ],
    TRANSFER_DATE_LESS_THAN_VAL_DATE => [
	92,
	undef,
	'the transfer valuation date must be greater than or equal to the member valuation date',
    ],
    TRANSFER_DATE_EXCEED_TRANSACTION_DATE => [
	93,
	undef,
	'the transfer valuation date may not exceed the transaction date',
    ],
    SELECTED_VALUE_GREATER_THAN_WITHDRAWAL_VALUE => [
	94,
	undef,
	'the selected value exceeds the withdrawal value',
    ],
    NO_INVESTMENTS_SELECTED => [
	95,
	undef,
	'no investments have been selected to transfer',
    ],
    AUTH_CODE => [
	96,
	undef,
	'Authorization code does not match invite.',
    ],
    MORE_THAN_ONE_WITHDRAWAL_ON_DATE => [
	97,
	undef,
	'the selected member already has a withdrawal on this date',
    ],
    START_DATE_GREATER_THAN_REPORT_DATE => [
	98,
	undef,
	'the start date may not be greater than the end date',
    ],
    START_DATE_LESS_THAN_FIRST_VALUATION_DATE => [
	99,
	undef,
	'the start date may not be less than the first valuation date',
    ],
    END_DATE_GREATER_THAN_TODAY => [
	100,
	undef,
	'the end date may not be greater than today',
    ],
    TICKER_NOT_FOUND => [
	101,
	undef,
	'ticker symbol not found',
    ],
    QUOTES_NOT_AVAILABLE_AT_START => [
	102,
	undef,
	'quotes for that ticker are not available from the specified start date',
    ],
    TICKER_LOOKUP_NOT_UNIQUE => [
	103,
	undef,
	'Unable to identify a unique club investment using that ticker.',
    ],
    INVALID_PERCENT => [
	104,
	undef,
	'the percentage must be between 0 and 100',
    ],
    TICKER_NOT_INVESTMENT_SOURCE => [
	105,
	undef,
	'the ticker may not be the same as the investment source',
    ],
    CHARGES_MAY_NOT_EXCEED_DISTRIBUTION => [
	106,
	undef,
	'the charges may not exceed the distribution amount',
    ],
    CORRUPT_ZIP_ARCHIVE => [
	107,
	undef,
	'the zip archive contains invalid data and cannot be read',
    ],
    NOT_ZERO => [
	108,
	undef,
	'may be not be zero',
    ],
    NO_FRACTION_SHARES_CREATED => [
	109,
	undef,
	'no fractional shares were created',
    ],
    PAYMENT_EXISTS_AFTER_WITH_FULL_WITHDRAWAL => [
	110,
	undef,
	'the member has a payment on or after the full withdrawal date',
    ],
    TRANSACTION_PRIOR_TO_MEMBER_DEPOSIT => [
	111,
	undef,
	'this transaction may only be entered on a date after member deposits',
    ],
    TRANSACTION_PRIOR_TO_ACQUISITION => [
	112,
	undef,
	'this transaction may only be entered on a date after the investment was acquired',
    ],
    USER_ALREADY_WITHDRAWN => [
	113,
	undef,
	'the user has already withdrawn from the club',
    ],
    ILLEGAL_FOREIGN_TAX_DISTRIBUTION => [
	114,
	undef,
	'foreign taxes may only be associated with dividend distributions',
    ],
    DATE_RANGE_OUTSIDE_OF_FISCAL_YEAR => [
	115,
	undef,
	'end date must be within the same year as the start date',
    ],
]);

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
