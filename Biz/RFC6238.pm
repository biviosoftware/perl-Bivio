# Copyright (c) 2025 bivio Software Artisans, Inc.  All Rights Reserved.
package Bivio::Biz::RFC6238;
use strict;
use Digest::SHA ();
use Bivio::Base 'Bivio.UNIVERSAL';

my($_DIGITS_POWER) = [map(10 ** $_, 0..8)];

sub compute {
    my($proto, $algorithm, $digits, $secret, $time_step) = @_;
    # See reference implementation: https://datatracker.ietf.org/doc/html/rfc6238#appendix-A
    my(@nibbles) = split('', _hash($proto, $algorithm, $secret, $time_step));
    my(@bytes);
    while (@nibbles) {
        push(@bytes, hex(shift(@nibbles) . shift(@nibbles)));
    }
    my($offset) = $bytes[-1] & 0xf;
    my($binary) =
        (($bytes[$offset] & 0x7f) << 24) |
        (($bytes[$offset + 1] & 0xff) << 16) |
        (($bytes[$offset + 2] & 0xff) << 8) |
        ($bytes[$offset + 3] & 0xff);
    return sprintf('%0' . $digits . 'd', $binary % $_DIGITS_POWER->[$digits]);
}

sub get_time_step {
    my($proto, $unixtime, $period) = @_;
    return int($unixtime / $period);
}

sub _hash {
    my($proto, $algorithm, $secret, $time_step) = @_;
    $algorithm = lc($algorithm);
    b_die('invalid algorithm=', $algorithm)
        unless $algorithm eq 'sha1' || $algorithm eq 'sha256' || $algorithm eq 'sha512';
    my($res);
    {
        no strict 'refs';
        $res = &{"Digest::SHA::hmac_${algorithm}_hex"}(pack('H*', _hex($time_step)), $secret);
    }
    return $res;
}

sub _hex {
    return sprintf("%016x", $_[0]);
}

1;
