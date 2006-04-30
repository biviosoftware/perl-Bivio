# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Random;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::MIME::Base64;
use IO::File ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub bytes {
    my($proto, $length) = @_;
    my($f, $res);
    return ($f = IO::File->new('< /dev/random'))
	&& defined($f->sysread($res, $length))
	&& defined($f->close)
	? $res : $proto->die("/dev/random: $!");
}

sub password {
    return Bivio::MIME::Base64->http_encode(shift->bytes(10));
}

1;
