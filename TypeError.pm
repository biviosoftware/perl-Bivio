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

#TODO: Make a list in doc here

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
	'invalid password; must be at least six characters',
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
	'there must be at least one Administrator in a club',
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
);

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
