# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::GeomPolygon;
use strict;
use Bivio::Base 'Type.Geom';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TE) = __PACKAGE__->use('Bivio::TypeError');
my($_GN) = __PACKAGE__->use('Type.GeomNumber');
my($_DD) = __PACKAGE__->use('Type.DecimalDegree');

sub TYPE {
    return 'POLYGON';
}

sub from_shape {
    my($proto, $shape) = @_;
    my($seen) = {};
    my($done);
    return $proto->new(
	'('
	    . join(',', map(
		join(' ', map($_DD->from_literal_or_die($_), $_->X, $_->Y)),
		$shape->points,
	    ))
	    . ')',
	undef,
	$proto->SRID_WGS84,
    );
}

sub validate_wkt {
    my($proto, $value) = @_;
    return $_TE->SYNTAX_ERROR
	unless $value =~ /^\((.+)\)$/s;
    my($i) = 0;
    foreach my $pair (split(/\s*,\s*/, $1)) {
	foreach my $d (split(' ', $pair, 2)) {
	    my(undef, $e) = $_GN->from_literal($d);
	    return $e
		if $e;
	}
	$i++;
    }
#TODO: Assumes syntax of WKT is a closed polygon.  Only can
#      really come from the database;
    return $i < 3 ? $_TE->TOO_FEW : ();
}

1;
