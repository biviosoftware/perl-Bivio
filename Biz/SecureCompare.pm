# Copyright (c) 2026 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::SecureCompare;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

# Constant-time string comparison for secret material (passwords, password
# hashes, TOTP codes, MACs).  A plain C<eq>/C<cmp> short-circuits on the first
# differing byte and leaks the matching prefix length via response timing.
# Length is intentionally not constant-time: inputs in this codebase are
# fixed-length per algorithm/format, so length leakage is not meaningful.

sub is_equal {
    my(undef, $a, $b) = @_;
    return 0
        unless defined($a) && defined($b);
    return 0
        unless length($a) == length($b);
    my($diff) = 0;
    for (my $i = 0; $i < length($a); $i++) {
        $diff |= ord(substr($a, $i, 1)) ^ ord(substr($b, $i, 1));
    }
    return $diff == 0 ? 1 : 0;
}

1;
