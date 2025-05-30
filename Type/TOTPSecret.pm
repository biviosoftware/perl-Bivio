# Copyright (c) 2025 bivio, Inc.  All rights reserved.
package Bivio::Type::TOTPSecret;
use strict;
use Bivio::Base 'Type.Secret';

my($_CHARS) = ['a'..'z', 'A'..'Z', '0'..'9'];
my($_CHARS_INDEX_MAX) = int(@$_CHARS) - 1;

sub generate_secret {
    my($proto, $algorithm) = @_;
    my($s) = '';
    for (0..$algorithm->get_secret_byte_count) {
        $s .= $_CHARS->[int(rand($_CHARS_INDEX_MAX) + 0.5)];
    }
    return $s;
}

# Not sure if should use
sub is_otp {
    return 1;
}

sub is_password {
    return 1;
}

sub is_secure_data {
    return 1;
}

1;
