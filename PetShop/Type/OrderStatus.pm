# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::OrderStatus;
use strict;
$Bivio::PetShop::Type::OrderStatus::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Type::OrderStatus::VERSION;

=head1 NAME

Bivio::PetShop::Type::OrderStatus - order status

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Type::OrderStatus;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::PetShop::Type::OrderStatus::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::PetShop::Type::OrderStatus>

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    UNKNOWN => [
    	0,
	'Unknown',
    ],
    PENDING => [
	1,
	'Pending',
    ],
    COMPLETED => [
	2,
	'Completed',
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
