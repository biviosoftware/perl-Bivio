# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECCreditCardExpMonth;
use strict;
$Bivio::Type::ECCreditCardExpMonth::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECCreditCardExpMonth::VERSION;

=head1 NAME

Bivio::Type::ECCreditCardExpMonth - list of credit card expiration months

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::ECCreditCardExpMonth;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ECCreditCardExpMonth::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ECCreditCardExpMonth> lists credit card expiration months

=cut

#=IMPORTS

#=VARIABLES

__PACKAGE__->compile([
    JANUARY => [1, '01'],
    FEBRUARY => [2, '02'],
    MARCH => [3, '03'],
    APRIL => [4, '04'],
    MAY => [5, '05'],
    JUNE => [6, '06'],
    JULY => [7, '07'],
    AUGUST => [8, '08'],
    SEPTEMBER => [9, '09'],
    OCTOBER => [10, '10'],
    NOVEMBER => [11, '11'],
    DECEMBER => [12, '12'],
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
