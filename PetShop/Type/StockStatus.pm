# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::StockStatus;
use strict;
$Bivio::PetShop::Type::StockStatus::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Type::StockStatus::VERSION;

=head1 NAME

Bivio::PetShop::Type::StockStatus - in stock status

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Type::StockStatus;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::PetShop::Type::StockStatus::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::PetShop::Type::StockStatus>

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    UNKNOWN => [
	0,
	'unknown',
    ],
    NOT_IN_STOCK => [
    	1,
	'no',
    ],
    IN_STOCK => [
	2,
	'yes',
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
