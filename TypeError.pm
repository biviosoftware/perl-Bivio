# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::TypeError;
use strict;
$Bivio::TypeError::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
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
);

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
