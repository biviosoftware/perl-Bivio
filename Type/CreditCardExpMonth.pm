# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::CreditCardExpMonth;
use strict;
$Bivio::Type::CreditCardExpMonth::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::CreditCardExpMonth::VERSION;

=head1 NAME

Bivio::Type::CreditCardExpMonth - list of credit card expiration months

=head1 SYNOPSIS

    use Bivio::Type::CreditCardExpMonth;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::CreditCardExpMonth::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::CreditCardExpMonth> lists credit card expiration months

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

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

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
