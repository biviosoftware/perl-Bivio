# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::CurrencyName;
use strict;
use Bivio::Base 'Type.SyntacticString';

my($_PAYPAL_CURRENCIES) = {
    map(($_ => 1),
        qw(AUD CAD CZK DKK EUR HKD HUF JPY NOK NZD PLN GBP SGD SEK CHF USD)),
};

sub REGEX {
    return qr{[a-z]{3}}i;
}

sub get_default {
    return 'USD';
}

sub get_width {
    return 3;
}

sub internal_post_from_literal {
    return uc($_[1]);
}

sub is_valid {
    my($proto, $value) = @_;
    #TODO(robnagler) share this, but want to be rigid here
    return ($value || '') =~ /^[A-Z]{3}$/s ? 1 : 0;
}

sub is_valid_paypal {
    my($proto, $value) = @_;
    return $_PAYPAL_CURRENCIES->{uc($value)} ? 1 : 0;
}

1;
