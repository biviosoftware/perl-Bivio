# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::MIME::Word;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Encode();
use MIME::Base64 ();

# See RFC 2047


sub decode {
    my(undef, $value) = @_;
    $value =~ s{(\?\=)\s*(\=\?)}{$1$2}gs;
    $value =~ s{\=\?([^?]*)\?([bq])\?([^?]+)\?\=}{
        _strip(
            $1,
            lc($2) eq 'q' ? _decode_q($3) : MIME::Base64::decode_base64($3),
        );
    }egisx;
    return $value;
}

sub _decode_q {
    my($v) = @_;
    $v =~ s/_/ /g;
    $v =~ s{=([\da-fA-F]{2})}{pack('C', hex($1))}ge;
    return $v;
}

sub _strip {
    my($encoding, $value) = @_;
    unless ($encoding =~ /^(ISO-8859-1|US-ASCII)$/i) {
        if ($encoding =~ /^UTF-8$/i) {
            utf8::decode($value);
        }
        elsif ($encoding =~ /^WINDOWS-1252/i) {
            $value = Encode::decode('WINDOWS-1252', $value);
        }
        else {
            $value =~ s{[\x80-\xFF]}{\?}g
        }
    }
    $value =~ s{\x00}{\?}g;
    return $value;
}

1;
