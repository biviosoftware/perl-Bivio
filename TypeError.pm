# Copyright (c) 1999,2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::TypeError;
use strict;
$Bivio::TypeError::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::TypeError::VERSION;

=head1 NAME

Bivio::TypeError - enum of errors in converting values

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::TypeError;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::TypeError::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::TypeError> The following are the base set of type error messages.

=over 4

=item UNKNOWN

=item INTEGER

expecting a number without a decimal point

=item NUMBER_RANGE

number outside of expected range

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

=item COUNTRY

country must be exactly two letters

=item PASSWORD

invalid password; must be at least SIX characters

=item REALM_NAME

The name you create must begin with a letter and only contain
letters, numbers, and underscores, and be at least
three characters long.

=item GREATER_THAN_ZERO

must be greater than zero

=item NOT_FOUND

not found

=item NOT_NEGATIVE

can not be negative

=item TOO_LONG

field is too long; there may be a problem with your browser

=item YEAR_DIGITS

four digit year required (mm/dd/yyyy)

=item EMAIL

invalid email address; should be of the form mary@aol.com

=item EMAIL_DOMAIN_LITERAL

email addresses with domain literals [w.x.y.z] are not acceptable

=item EMAIL_UNQUALIFIED

email does not contain a @domain.com

=item DEMO_CLUB_SUFFIX

name may not end in _demo_club

=item UNSPECIFIED

field may not be unspecified

=item TEXT_TOO_LONG

input is too long.  Maximum size is 500 characters

=item FORM_DATA_MULTIPART_MIXED

only one file may be uploaded at a time

=item PRIMARY_ID

invalid URL, query string is invalid

=item FILE_FIELD_RESET_FOR_SECURITY

your browser reset this field for security reasons

=item FILE_NAME

File names may not contain \\, /, :, *, ?, ", <, >, or |.  They may not
be equal to "." or "..". or contain control characters or tabs.

=item NOT_ZERO

may be not be zero

=item TIME_COMPONENT_OF_DATE

time component not valid for date value

=item TIME_RANGE

seconds outside of the maximum for a time

=item DATE_RANGE

days outside of the maximum for a date

=item PASSWORD_MISMATCH

invalid password

=back

=cut

#=IMPORTS

#=VARIABLES

my($_CFG) = Bivio::IO::ClassLoader->delegate_require_info(__PACKAGE__);

__PACKAGE__->compile([
    @$_CFG,
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
	'field is too long; there may be a problem with your browser',
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
    DEMO_CLUB_SUFFIX => [
	26,
	undef,
	'name may not end in _demo_club',
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
	'may be not be zero',
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
    PASSWORD_MISMATCH => [
	37,
	undef,
	'invalid password',
    ],
]);

=head1 METHODS

=cut

=for html <a name="is_continuous"></a>

=head2 static is_continuous() : false

Task Ids aren't continuous.  Tasks can go away.

=cut

sub is_continuous {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
