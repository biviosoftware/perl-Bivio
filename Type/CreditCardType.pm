# Copyright (c) 2000-2002 bivio Inc.  All rights reserved.
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
	'Visa',
    ],
    MASTERCARD => [
        2,
	'MasterCard',
    ],
    AMEX => [
        3,
	'Amex',
	'American Express',
    ],
]);

=head1 METHODS

=cut

=for html <a name="get_by_number"></a>

=head2 static get_by_number(string number) : Bivio::Type::CreditCard

Given a card I<number>, return its type  Handles C<undef> as unknown.

=cut

sub get_by_number {
    my($proto, $number) = @_;
    return Bivio::Type::CreditCardType->UNKNOWN unless defined($number);
    $number =~ s/\s+//g;
    return Bivio::Type::CreditCardType->UNKNOWN if $number =~ /\D/;
    my($len) = length($number);
    return Bivio::Type::CreditCardType->VISA
            if ($len == 13 || $len == 16) && $number =~ /^4/;
    return Bivio::Type::CreditCardType->MASTERCARD
            if $len == 16 && $number =~ /^5[1-5]/;
    return Bivio::Type::CreditCardType->AMEX
            if $len == 15 && $number =~ /^3[47]/;
#    return Bivio::Type::CreditCardType->DISCOVER
#            if $len == 15 && $number =~ /^6/;
#    return Bivio::Type::CreditCardType->DINERS
#            if $len == 15 && $number =~ /^3[068]/;
#    return Bivio::Type::CreditCardType->JCB
#            if $len == 15 && $number =~ /^35/;
    return Bivio::Type::CreditCardType->UNKNOWN;
}

=for html <a name="is_supported_by_number"></a>

=head2 static is_supported_by_number(string number) : boolean

Returns true if CC is supported.

=cut

sub is_supported_by_number {
    return shift->get_by_number(@_)->equals_by_name('UNKNOWN') ? 0 : 1;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000-2002 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
