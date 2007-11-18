# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::GeomPoint;
use strict;
use Bivio::Base 'Type.Geom';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DD) = __PACKAGE__->use('Type.DecimalDegree');

sub TYPE {
    return 'POINT';
}

sub from_long_lat {
    my($proto, $long, $lat) = @_;
    return $proto->new(
	join(' ', map($_DD->from_literal_or_die($_), $long, $lat)));
}

sub validate_wkt {
    my($proto, $value) = @_;
    return map({
	my(undef, $e) = $_DD->from_literal($_);
	$e ? $e : ();
    } split(' ', $value));
}

1;
