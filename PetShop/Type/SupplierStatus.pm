# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::SupplierStatus;
use strict;
$Bivio::PetShop::Type::SupplierStatus::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Type::SupplierStatus::VERSION;

=head1 NAME

Bivio::PetShop::Type::SupplierStatus - supplier status

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Type::SupplierStatus;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::PetShop::Type::SupplierStatus::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::PetShop::Type::SupplierStatus>

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    UNKNOWN => [
    	0,
	'Unknown',
    ],
    PREFERRED => [
	1,
	'Preferred',
    ],
    APPROVED => [
	2,
	'Approved'
    ],
    ON_HOLD => [
	3,
	'On-hold',
    ],
    SUSPENDED => [
	4,
	'Suspended',
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
