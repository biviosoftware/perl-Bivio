# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Auth::RealmType;
use strict;
$Bivio::Auth::RealmType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Auth::RealmType::VERSION;

=head1 NAME

Bivio::Auth::RealmType - enum of authentication realm types

=head1 RELEASE SCOPE

bOP

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

realm has not been determined

=item GENERAL

access to general areas (not club or user specific)

=item USER

access to a particular user

=item CLUB

access to a particular club

=cut

#=IMPORTS

#=VARIABLES

#=PRIVATE METHODS

__PACKAGE__->compile([
    'UNKNOWN' => [
    	0,
	undef,
	'realm has yet to be established',
    ],
    'GENERAL' => [
	1,
	undef,
	'access to general areas (not club or user specific)',
    ],
    'USER' => [
	2,
	undef,
	'access to a particular user',
    ],
    'CLUB' => [
	3,
	undef,
	'access to a particular club',
    ],
]);

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
