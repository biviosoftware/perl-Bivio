# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::Category;
use strict;
$Bivio::PetShop::Type::Category::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Type::Category::VERSION;

=head1 NAME

Bivio::PetShop::Type::Category - product category choices

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Type::Category;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::PetShop::Type::Category::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::PetShop::Type::Category>

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    UNKNOWN => [
    	0,
	'Unknown',
    ],
    BIRDS => [
	1,
	'Birds',
	'Exotic Varieties',
    ],
    CATS => [
	2,
	'Cats',
	'Various Breeds, Exotic Varieties',
    ],
    DOGS => [
	3,
	'Dogs',
	'Various Breeds',
    ],
    FISH => [
	4,
	'Fish',
	'Saltwater, Freshwater',
    ],
    REPTILES => [
	5,
	'Reptiles',
	'Lizards, Turtles, Snakes',
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
