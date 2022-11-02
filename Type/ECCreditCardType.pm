# Copyright (c) 2000-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECCreditCardType;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => [0],
    VISA => [1],
    MASTERCARD => [2, 'MasterCard'],
    AMEX => [3, 'Amex', 'American Express'],
    DISCOVER => [4],
]);

b_use('IO.Config')->register({
    supported_card_list => 'VISA MASTERCARD AMEX DISCOVER',
});
my($_SUPPORTED_CARDS);

sub get_by_number {
    # (proto, string) : Type.ECCreditCard
    # Given a card I<number>, return its type  Handles C<undef> as unknown.
    my($proto, $number) = @_;
    return $proto->UNKNOWN unless defined($number);
    $number =~ s/\s+//g;
    return $proto->UNKNOWN if $number =~ /\D/;
    my($len) = length($number);
    return $proto->VISA
            if ($len == 13 || $len == 16) && $number =~ /^4/;
    return $proto->MASTERCARD
            if $len == 16 && $number =~ /^5[1-5]/;
    return $proto->AMEX
            if $len == 15 && $number =~ /^3[47]/;
    return $proto->DISCOVER
            if $len == 16 && $number =~ /^6011/;
    return $proto->UNKNOWN;
}

sub handle_config {
    # (proto, hash) : undef
    # supported_card_list : string
    #
    # List of supported card enum names.
    # Defaults to 'VISA MASTERCARD AMEX DISCOVER'.
    my($proto, $cfg) = @_;

    # map of enum name values, ensures they are valid before adding
    $_SUPPORTED_CARDS = {
        map {$proto->from_name($_)->get_name => 1}
            split(' ', $cfg->{supported_card_list}),
    };
    return;
}

sub is_supported_by_number {
    # (proto, string) : boolean
    # Returns true if CC is supported.
    my($self, $number) = @_;
    return $_SUPPORTED_CARDS->{$self->get_by_number($number)->get_name}
        ? 1 : 0;
}

1;
