# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::EntityLocation;
use strict;
$Bivio::PetShop::Type::EntityLocation::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Type::EntityLocation::VERSION;

=head1 NAME

Bivio::PetShop::Type::EntityLocation - address/phone location

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Type::EntityLocation;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::PetShop::Type::EntityLocation::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::PetShop::Type::EntityLocation>

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    UNKNOWN => [
    	0,
	'Unknown',
    ],
    PRIMARY => [
	1,
	'Primary',
    ],
    BILL_TO => [
	2,
	'Bill to',
    ],
    SHIP_TO => [
	3,
	'Ship to',
    ],
]);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
