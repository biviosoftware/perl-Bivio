# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::SHA1;
use strict;
use Bivio::Base 'Type.Name';
use Digest::SHA1 ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub compare {
    my($proto, $sha1, $incoming) = @_;
    return 1 unless defined($sha1) && defined($incoming);
    return $sha1 cmp $proto->from_literal($incoming);
}

sub from_literal {
    my($proto, $value) = @_;
    return Digest::SHA1::sha1_base64(defined($value) ? $value : '');
}

1;
