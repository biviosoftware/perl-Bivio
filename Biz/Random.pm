# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Random;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::MIME::Base64;
use IO::File ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DEV) = -r '/dev/urandom' ? '/dev/urandom'
    : -r '/dev/random' ? '/dev/random' : undef;

sub bytes {
    my($proto, $length) = @_;
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
    return substr(
	unpack('h*', shift->bytes(int(($length + 1) / 2))),
	0,
	$length,
    );
}

sub integer {
    my($proto, $ceiling) = @_;
    if (defined($ceiling)) {
	Bivio::Die->die($ceiling, ': ceiling must be positive')
            unless $ceiling > 0;
    }
    else {
	$ceiling = $proto->use('Type.Integer')->get_max;
    }
    return unpack('L', $proto->bytes(4)) % $ceiling;
}

sub password {
    return Bivio::MIME::Base64->http_encode(shift->bytes(12));
}

sub string {
    my($proto, $length, $chars) = @_;
    $chars ||= [0..9, 'a' .. 'z'];
    return join('', map(
	$chars->[ord($_) % @$chars],
	split(//, $proto->bytes($length)),
    ));
}

1;
