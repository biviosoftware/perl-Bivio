# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::UserType;
use strict;
$Bivio::PetShop::Type::UserType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Type::UserType::VERSION;

=head1 NAME

Bivio::PetShop::Type::UserType - customer types

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Type::UserType;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::PetShop::Type::UserType::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::PetShop::Type::UserType>

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    UNKNOWN => [
    	0,
	'Unknown',
    ],
    HOME_CONSUMER => [
	1,
	'Home Consumer',
    ],
    COMMERCIAL_BUSINESS => [
	2,
	'Commercial Business',
    ],
    WHOLE_SELLER => [
	3,
	'Whole Seller',
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
