# Copyright (c) 2001-2005 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimpleTypeError;
use strict;
$Bivio::Delegate::SimpleTypeError::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::SimpleTypeError::VERSION;

=head1 NAME

Bivio::Delegate::SimpleTypeError - default type errors

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::SimpleTypeError;

=cut

use Bivio::Delegate;
@Bivio::Delegate::SimpleTypeError::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::Delegate::SimpleTypeError> returns default TypeErrors for
simplest bOP site.

You can extend this delegate with:

    sub get_delegate_info {
	return [
	    @{Bivio::Delegate::SimpleTypeError->get_delegate_info()},
	    ...my TypeErrors...
	];
    }

Start your TypeErrors at 501.  Don't worry about dups, because
L<Bivio::Type::Enum|Bivio::Type::Enum> will die if you overlap.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 static get_delegate_info() : array_ref

Returns the task declarations.

=cut

sub get_delegate_info {
    return [
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
    DATE_TIME => [
	3,
	undef,
	'date time must be number of seconds since Jan 1, 1970',
    ],
    DATE => [
	4,
	undef,
	'invalid date format, must be mm/dd/yyyy',
    ],
    TIME => [
	5,
	undef,
	'invalid time format, must be hh:mm, hh:mm a, hh:mm:ss p',
    ],
    NUMBER => [
	6,
	undef,
	'expecting a number',
    ],
    YEAR_RANGE => [
	7,
	undef,
	'year outside of valid range (1800 to 2199)',
    ],
    EXISTS => [
	8,
	undef,
	'already exists',
    ],
    MONTH => [
	9,
	undef,
	'invalid month',
    ],
    DAY_OF_MONTH => [
	10,
	undef,
	'invalid day for this month',
    ],
    HOUR => [
	11,
	undef,
	'invalid hour',
    ],
    MINUTE => [
	12,
	undef,
	'invalid minute',
    ],
    SECOND => [
	13,
	undef,
	'invalid second',
    ],
    NULL => [
	14,
	undef,
	'field may not be empty',
    ],
    COUNTRY => [
	15,
	undef,
	'country must be exactly two letters',
    ],
    PASSWORD => [
	16,
	undef,
	'invalid password; must be at least SIX characters',
    ],
    REALM_NAME => [
	17,
	undef,
	'The name you create must begin with a letter and only contain'
	.' letters, numbers, and underscores, and be at least'
	.' three characters long.',
    ],
    GREATER_THAN_ZERO => [
	18,
	undef,
	'must be greater than zero',
    ],
    NOT_FOUND => [
	19,
	undef,
	'not found',
    ],
    NOT_NEGATIVE => [
	20,
	undef,
	'can not be negative',
    ],
    TOO_LONG => [
	21,
	undef,
	'field is too long',
    ],
    YEAR_DIGITS => [
	22,
	undef,
	'four digit year required (mm/dd/yyyy)',
    ],
    EMAIL => [
	23,
	undef,
	'invalid email address; should be of the form mary@aol.com',
    ],
    EMAIL_DOMAIN_LITERAL => [
	24,
	undef,
	'email addresses with domain literals [w.x.y.z] are not acceptable',
    ],
    EMAIL_UNQUALIFIED => [
	25,
	undef,
	'email does not contain a @domain.com',
    ],
    PASSWORD_MISMATCH => [
	26,
	undef,
	'The password you entered does not match the value stored in our database. Please remember that passwords are case-sensitive, i.e. "HELLO" is not the same as "hello".',
    ],
    UNSPECIFIED => [
	27,
	undef,
	'field may not be unspecified',
    ],
    TEXT_TOO_LONG => [
	28,
	undef,
	'input is too long.  Maximum size is 500 characters.',
    ],
    FORM_DATA_MULTIPART_MIXED => [
	29,
	undef,
	'only one file may be uploaded at a time',
    ],
    PRIMARY_ID => [
	30,
	undef,
	'invalid URL, query string is invalid',
    ],
    FILE_FIELD_RESET_FOR_SECURITY => [
	31,
	undef,
	# Real message in FormErrors.  Have one here just in case.
	'your browser reset this field for security reasons',
    ],
    FILE_NAME => [
	32,
	undef,
	'File names may not contain \\, /, :, *, ?, ", <, >, or |.  They may not be equal to "." or "..". or contain control characters or tabs.',
    ],
    NOT_ZERO => [
	33,
	undef,
	'may not be zero',
    ],
    TIME_COMPONENT_OF_DATE => [
	34,
	undef,
	'time component not valid for date value',
    ],
    TIME_RANGE => [
	35,
	undef,
	'seconds outside of the maximum for a time',
    ],
    DATE_RANGE => [
	36,
	undef,
	'days outside of the maximum for a date',
    ],
    US_ZIP_CODE => [
	37,
	undef,
	'invalid US Zip; must be 5 or 9 digits.',
    ],
    CREDITCARD_INVALID_NUMBER => [
	38,
	undef,
	"not a valid credit card number",
    ],
    CREDITCARD_EXPIRED => [
	39,
	undef,
	"expiration date is in the past",
    ],
    CREDITCARD_UNSUPPORTED_TYPE => [
	40,
	undef,
	"credit card type not supported; Amex, Visa and MasterCard only",
    ],
    CREDITCARD_WRONG_TYPE => [
	41,
	undef,
	"card number does not match card type",
    ],
    FILE_FIELD => [
	42,
	undef,
	'your browser has not submitted the file correctly; please try again',
    ],
    EMPTY => [
	43,
	undef,
	'file cannot be empty',
    ],
    OFFLINE_USER => [
	44,
	undef,
	'operation not allowed for offline user',
    ],
    CONFIRM_PASSWORD => [
	45,
	undef,
	'password and confirm password fields do not match',
    ],
    DOMAIN_NAME => [
	46,
	undef,
	'invalid internet domain name',
    ],
    INVALID_MESSAGE_BODY => [
        47,
        undef,
        'message body must be plain text or HTML',
    ],
    FIRST_NAME_LENGTH => [
	48,
	undef,
	'first name is too long',
    ],
    MIDDLE_NAME_LENGTH => [
	49,
	undef,
	'middle name is too long',
    ],
    LAST_NAME_LENGTH => [
	50,
	undef,
	'last name is too long',
    ],
    HTTPURI => [
	51,
	undef,
	'invalid HTTP URL (web location)',
    ],
];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001-2005 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
