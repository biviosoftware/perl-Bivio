# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Random;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::MIME::Base64;
use IO::File ();

my($_DEV) = -r '/dev/urandom' ? '/dev/urandom'
    : -r '/dev/random' ? '/dev/random' : undef;

sub bytes {
    my($proto, $length) = @_;
    $length = b_use('Type.Integer')->from_literal_or_die($length);
    my($f, $res);
    return $_DEV
        ? ($f = IO::File->new("< $_DEV"))
            && defined($f->sysread($res, $length))
            && defined($f->close)
            ? $res : $proto->die("$_DEV: $!")
        : substr(
            pack('L', int(rand(0xffffffff))) x int(($length + 3)/4),
            0,
            $length,
        );
}

sub hex_digits {
    my($proto, $length) = @_;
    $length = b_use('Type.Integer')->from_literal_or_die($length);
    return substr(
        unpack('h*', shift->bytes(int(($length + 1) / 2))),
        0,
        $length,
    );
}

sub integer {
    my($proto, $ceiling, $floor) = @_;
    if (defined($ceiling)) {
        b_die($ceiling, ': ceiling must be positive')
            unless $ceiling > 0;
    }
    else {
        $ceiling = $proto->use('Type.Integer')->get_max;
    }
    if (defined($floor)) {
        b_die($floor, ': floor must be non-negative')
            unless $floor >= 0;
    }
    else {
        $floor = 0;
    }
    b_die($floor, ': floor must be less than ceiling: ', $ceiling)
        unless $ceiling > $floor;
    return unpack('L', $proto->bytes(4)) % ($ceiling - $floor) + $floor;
}

sub password {
    return Bivio::MIME::Base64->http_encode(shift->bytes(12));
}

sub string {
    my($proto, $length, $chars) = @_;
    $length ||= 8;
    $chars ||= [0..9, 'a' .. 'z'];
    return join('', map(
        $chars->[ord($_) % @$chars],
        split(//, $proto->bytes($length)),
    ));
}

1;
