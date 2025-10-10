# Copyright (c) 2025 bivio, Inc.  All rights reserved.
package Bivio::Type::TOTPSecret;
use strict;
use Bivio::Base 'Type.SecretLine';

my($_A) = b_use('Type.TOTPAlgorithm');
my($_TE) = b_use('Bivio.TypeError');
# TODO: more chars
my($_CHARS) = ['a'..'z', 'A'..'Z', '0'..'9'];
my($_CHARS_INDEX_MAX) = int(@$_CHARS) - 1;

sub from_literal {
    my($proto, $value) = @_;
    use bytes;
    my($l) = bytes::length($value // '');
    foreach my $a ($_A->get_non_zero_list) {
        return $proto->SUPER::from_literal($value)
            if $l == $a->get_secret_byte_count;
    }
    return (undef, $_TE->SYNTAX_ERROR);
}

sub generate_secret {
    my($proto, $algorithm) = @_;
    my($s) = '';
    for (1..$algorithm->get_secret_byte_count) {
        $s .= $_CHARS->[int(rand($_CHARS_INDEX_MAX) + 0.5)];
    }
    return $s;
}

1;
