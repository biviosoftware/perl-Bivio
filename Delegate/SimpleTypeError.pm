# Copyright (c) 2001-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimpleTypeError;
use strict;
use Bivio::Base 'Bivio::Delegate';

# C<Bivio::Delegate::SimpleTypeError> returns default TypeErrors for
# simplest bOP site.
#
# You can extend this delegate with:
#
#     sub get_delegate_info {
# 	return [
# 	    @{Bivio::Delegate::SimpleTypeError->get_delegate_info()},
# 	    ...my TypeErrors...
# 	];
#     }
#
# Start your TypeErrors at 501.  Don't worry about dups, because
# L<Bivio::Type::Enum|Bivio::Type::Enum> will die if you overlap.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    # Returns the task declarations.
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
	'invalid date-time. Some possible formats are: mm/dd/yyyy hh:mm:ss and yyyymmddhhmmss',
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
	'field must be specified',
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
    HTTP_URI => [
	51,
	undef,
	'invalid HTTP URL (web location)',
    ],
    US_ZIP_CODE_9 => [
	52,
	undef,
	'Nine (9) digit US Zip code required',
    ],
    FILE_PATH => [
	53,
	undef,
	'File paths may not contain \\, :, *, ?, ", <, >, |, tabs, control characters, leading or trailing dots.',
    ],
    PASSWORD_QUERY_SUPER_USER => [
	54,
	undef,
	'You are not allowed to reset your password.  Please contact your system administrator for password assistance.',
    ],
    FORUM_NAME => [
	55,
	undef,
	'The first part of a forum name must be three or more characters and consist of alphanumeric characters followed by any number of hyphens and alphanumeric characters.',
    ],
    TOP_FORUM_NAME => [
	56,
	undef,
	'Top forum name not formed incorrectly.  Must not contain hyphens (-).',
    ],
    TOP_FORUM_NAME_CHANGE => [
	57,
	undef,
	'Top forum name may not be changed',
    ],
    EMAIL_ALIAS_OUTGOING => [
	58,
	undef,
	'Outgoing email alias values must be an email address or simple name',
    ],
    TIME_ZONE => [
	59,
	undef,
	'Unknown or invalid time zone in date',
    ],
    WIKI_NAME => [
	60,
	undef,
	'Wiki page names must be mixed case words starting with an upper-case letter, containing at least one lower case letter between two upper case letters, and containing only numbers and letters (no spaces, underscores, etc.)',
    ],
    BLOG_NAME => [
	61,
	undef,
	'Blog page names may only containg letters, numbers and spaces.',
    ],
    BLOG_FILE_NAME => [
	62,
	undef,
	'Blog identifiers must be of the form: YYYYMMDDHHMMSS',
    ],
    BLOG_TITLE_NULL => [
	63,
	undef,
	'Blog must start with a title of the form: @h3 some title',
    ],
    BLOG_BODY_NULL => [
	64,
	undef,
	'Blog body must contain some text after the title (@h3 line)',
    ],
    BLOG_TITLE_PREFIX => [
	65,
	undef,
	'Blog must start with "@h3 " to indicate title',
    ],
    MUTUALLY_EXCLUSIVE => [
	66,
	undef,
	'Two or more mutually exclusive values cannot be specified',
    ],
    INVALID_END_DATETIME => [
	67,
	undef,
	'The end date and time cannot be before or equal to the start date and time',
    ],
    SYNTAX_ERROR => [
	68,
	undef,
	'Invalid value',
    ],
    SIMPLE_CLASS_NAME => [
	69,
	undef,
	'Class names must consist of letters, numbers, or underscores',
    ],
    TOO_MANY => [
	70,
	undef,
	'field has too many values',
    ],
];
}

1;
