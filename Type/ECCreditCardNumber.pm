# Copyright (c) 2000-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECCreditCardNumber;
use strict;
use Bivio::Base 'Type.Secret';

my($_TE) = b_use('Bivio.TypeError');

sub TEST_NUMBER {
    return '4222 2222 2222 2';
}

sub from_literal {
    my($proto, $value) = @_;
    my($err);
    ($value, $err) = $proto->SUPER::from_literal($value);
    return ($value, $err)
        if $err;
    return undef
        unless defined($value);
    $value =~ s/[-\s]+//g;
    return $proto->luhn_mod10($value) ? $value :
            (undef, $_TE->CREDITCARD_INVALID_NUMBER);
}

sub get_width {
    return 19;
}

sub luhn_mod10 {
    my(undef, $number) = @_;
    return 0
        unless defined($number);
    my($len) = length($number);
    return 0
        if $len < 12 || $len > 19 || $number =~ /\D/;
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
