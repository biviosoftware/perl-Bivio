# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::CreditCardType;
use strict;
$Bivio::Type::CreditCardType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::CreditCardType::VERSION;

=head1 NAME

Bivio::Type::CreditCardType - supported credit card types

=head1 SYNOPSIS

    use Bivio::Type::CreditCardType;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::CreditCardType::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::CreditCardType> lists the currently supported credit card types.

=over 4

=item VISA

=item MASTERCARD

=item AMEX

Not yet supported.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

__PACKAGE__->compile([
    UNKNOWN => [
        0,
    ],
    VISA => [
        1,
    ],
    MASTERCARD => [
        2,
    ],
    AMEX => [
        3,
    ],
]);

=head1 METHODS

=cut

=for html <a name="get_by_number"></a>

=head2 get_by_number(string number) : Bivio::Type::CreditCard

Given a card I<number>, return its type

=cut

sub get_by_number {
    my($proto, $number) = @_;
    $number =~ s/\s+//g;
    return Bivio::Type::CreditCardType::UNKNOWN()
            if $number =~ /\D/;
    my($len) = length($number);
    return Bivio::Type::CreditCardType::VISA()
            if ($len == 13 || $len == 16) && $number =~ /^4/;
    return Bivio::Type::CreditCardType::MASTERCARD()
            if $len == 16 && $number =~ /^5[1-5]/;
    return Bivio::Type::CreditCardType::AMEX()
            if $len == 15 && $number =~ /^3[47]/;
    return Bivio::Type::CreditCardType::UNKNOWN();
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
