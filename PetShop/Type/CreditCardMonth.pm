# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::CreditCardMonth;
use strict;
$Bivio::PetShop::Type::CreditCardMonth::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Type::CreditCardMonth::VERSION;

=head1 NAME

Bivio::PetShop::Type::CreditCardMonth - credit card month values

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Type::CreditCardMonth;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::PetShop::Type::CreditCardMonth::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::PetShop::Type::CreditCardMonth>

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    JANUARY => [
        1,
        '01',
    ],
    FEBRUARY => [
        2,
        '02',
    ],
    MARCH => [
        3,
        '03',
    ],
    APRIL => [
        4,
        '04',
    ],
    MAY => [
        5,
        '05',
    ],
    JUNE => [
        6,
        '06',
    ],
    JULY => [
        7,
        '07',
    ],
    AUGUST => [
        8,
        '08',
    ],
    SEPTEMBER => [
        9,
        '09',
    ],
    OCTOBER => [
        10,
        '10',
    ],
    NOVEMBER => [
        11,
        '11',
    ],
    DECEMBER => [
        12,
        '12',
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
