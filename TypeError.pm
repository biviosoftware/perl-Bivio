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
use Bivio::TypeError;

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
    DATE_RANGE => [
	8,
	undef,
	'date outside of valid range (1970 to 2038)',
    ],
    TIME_RANGE => [
	9,
	undef,
	'date outside of valid range (years 1970 to 2037)',
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
	'invalid name syntax; must begin with a letter,'
	. ' contain letters, numbers, and underscores,'
	. ' and be at least three characters',
    ],
    EXISTS => [
	20,
	undef,
	'name already exists',
    ],
);

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
