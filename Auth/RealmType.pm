# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Auth::RealmType;
use strict;
$Bivio::Auth::RealmType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Auth::RealmType - enum of authentication realm types

=head1 SYNOPSIS

    use Bivio::Auth::RealmType;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Auth::RealmType::ISA = qw(Bivio::Type::Enum);

=head1 DESCRIPTION

C<Bivio::Auth::RealmType> defines the kinds of realms in which
requests are authenticated.

The following realm types are defined:

=over 4

=item UNKNOWN

unknown: realm has not been determined

=item CLUB

club: realm is a club object.

=cut

#=IMPORTS

#=VARIABLES

#=PRIVATE METHODS

__PACKAGE__->compile(
    'UNKNOWN' => [
    	0,
	'unknown',
	'realm has yet to be established',
    ],
    'PUBLIC' => [
	1,
	'public',
	'no access restrictions',
    ],
    'ANY_USER' => [
	2,
	'any user',
	'access to user-only areas',
    ],
    'ANY_MEMBER' => [
	3,
	'any user',
	'access to club member-only areas',
    ],
    'USER' => [
	4,
	'user',
	'access to a particular user',
    ],
    'CLUB' => [
	5,
	'club',
	'access to a particular club',
    ],
);

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
