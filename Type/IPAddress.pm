# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::IPAddress;
use strict;
use Bivio::Base 'Type.SyntacticString';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REGEX {
    return qr{(?:\d{1,3}\.){3}\d{1,3}}i;
}

sub from_domain {
    my($proto, $host) = @_;
    return $proto->from_inet(
	(gethostbyname($host))[4] || b_die($host, ': gethostbyname: ', "$!"));
}

sub from_inet {
    my(undef, $inet_addr) = @_;
    return join('.', unpack('C4', $inet_addr));
}

sub get_min_width {
    return 7;
}

sub get_width {
    return 15;
}

1;
