# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::CookieState;
use strict;
$Bivio::Agent::HTTP::CookieState::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::HTTP::CookieState - state of the request cookie

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::CookieState;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Agent::HTTP::CookieState::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::CookieState>

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    UNKNOWN => [
	0,
    ],
    OK => [
	1,
	undef,
	'cookie is valid',
    ],
    INVALID_VERSION => [
	2,
	undef,
	'cookie contains invalid version',
    ],
    INVALID_CLIENT => [
	3,
	undef,
	'cookie contains invalid client remote ip address',
    ],
    NO_EXPIRES => [
	4,
	undef,
	'cookie is missing expires field',
    ],
    EXPIRED => [
	5,
	undef,
	'cookie has expired',
    ],
    NOT_SET => [
	6,
	undef,
	'cookie was not set on request',
    ],
    NO_VERSION => [
	7,
	undef,
	'cookie is missing version',
    ],
    NO_CLIENT => [
	8,
	undef,
	'cookie is missing client remote ip address',
    ],
    INVALID => [
	9,
	undef,
	'cookie invalid in some unexpected way',
    ],
    INVALID_USER => [
	10,
	undef,
	'cookie contains invalid user id',
    ],
    NO_DATA => [
	11,
	undef,
	'cookie is missing data (user, etc.)',
    ],
);

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
