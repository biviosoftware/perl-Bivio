# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::GeomPoint;
use strict;
use Bivio::Base 'Type.Geom';

my($_TE) = b_use('Bivio::TypeError');
my($_GN) = b_use('Type.GeomNumber');
my($_DD) = b_use('Type.DecimalDegree');

sub TYPE {
    return 'POINT';
}

sub from_long_lat {
    my($proto, $long, $lat) = @_;
    return $proto->new(
	join(' ', map($_DD->from_literal_or_die($_), $long, $lat)),
	undef,
	$proto->SRID_WGS84,
    );
}

sub validate_wkt {
    my($proto, $value) = @_;
    my($i) = 0;
    foreach my $d (split(' ', $value)) {
	my(undef, $e) = $_GN->from_literal($d);
	return $e
	    if $e;
	$i++;
    }
    return $i < 2 ? $_TE->TOO_FEW : $i > 2 ? $_TE->TOO_MANY : ();
}

1;
