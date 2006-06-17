# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Random;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::MIME::Base64;
use IO::File ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DEV) = -r '/dev/random' ? 1 : 0;

sub bytes {
    my($proto, $length) = @_;
    my($f, $res);
    return $_DEV
	? ($f = IO::File->new('< /dev/random'))
	    && defined($f->sysread($res, $length))
	    && defined($f->close)
	    ? $res : $proto->die("/dev/random: $!")
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

sub password {
    return Bivio::MIME::Base64->http_encode(shift->bytes(12));
}

sub string {
    my($proto, $length, $chars) = @_;
    return join('', map(
	$chars->[ord($_) % @$chars],
	split(//, $proto->bytes($length)),
    ));
}

1;
