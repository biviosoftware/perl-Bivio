# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECCreditCardNumber;
use strict;
use Bivio::Base 'Bivio::Type::Secret';

# C<Bivio::Type::ECCreditCardNumber> interprets a string as a credit card number.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);

sub TEST_NUMBER {
    # : string
    # Returns a valid test credit card number.
    return '4222 2222 2222 2';
}

sub from_literal {
    # (proto, string) : array
    # Returns C<undef> if the value is empty or does not pass the Luhn test
    my($proto, $value) = @_;
    my($err);
    ($value, $err) = $proto->SUPER::from_literal($value);
    return ($value, $err) if $err;
    return undef unless defined($value);

    # Remove dashes and spaces to be friendly
    $value =~ s/[-\s]+//g;
    return $proto->luhn_mod10($value) ? $value :
            (undef, Bivio::TypeError::CREDITCARD_INVALID_NUMBER());
}

sub get_width {
    # (self) : int
    # Returns the maximum width of a credit card.
    return 19;
}

sub luhn_mod10 {
    # (self, string) : boolean
    # Returns TRUE if I<number> passes the Luhn Mod-10 test
    my(undef, $number) = @_;
    return 0 unless defined($number);
    my($len) = length($number);
    return 0 if $len < 12 || $len > 19 || $number =~ /\D/;

    my($sum) = 0;
    my($mul) = 1;
    my(@digits) = split('', $number);
    for (my $i = $len-1; $i >= 0; $i--) {
        $a = $digits[$i] * $mul;
        $sum += $a % 10 + ($a > 9 ? 1 : 0);
        $mul = $mul == 1 ? 2 : 1;
    }
    return ($sum % 10) == 0 ? 1 : 0;
}

1;
