# Copyright (c) 2002-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::USZipCode;
use strict;
use Bivio::Base 'Type.SyntacticString';

my($_PI_180) = atan2(1, 1) * 4 / 180.0;

sub REGEX {
    return qr{(\d{5}(?:\d{4})?)};
}

sub SYNTAX_ERROR {
    return Bivio::TypeError->US_ZIP_CODE;
}

sub internal_pre_from_literal {
    my($proto, $value) = @_;
    $value =~ s/[-\s]+//g;
    return $value;
}

sub zip_codes_by_proximity {
    my($proto, $zip, $search_zip_codes) = @_;
    my($res) = [];
    my($map) = b_use('Type.USZipCodeMap')->get_location_by_zipcode;
    my($search_lat_lon) = $map->{_zip5($zip)};
    return $res unless $search_lat_lon;

    foreach my $z (map(_zip5($_), @$search_zip_codes)) {
	my($lat_lon) = $map->{$z};
	push(@$res, [$z, @$lat_lon,
	    _great_circle_distance(@$search_lat_lon, @$lat_lon)])
	    if $lat_lon;
    }
    @$res = sort({$a->[3] <=> $b->[3]} @$res);
    return $res;
}

sub _great_circle_distance {
    my($lon1, $lat1, $lon2, $lat2) = map($_ * $_PI_180, @_);
    my($dist) = sin(($lat2 - $lat1) / 2.0) ** 2
	+ cos($lat1) * cos($lat2) * sin(($lon2 - $lon1) / 2.0) ** 2;
    return 7912 * atan2(sqrt($dist), sqrt(1 - $dist));
}

sub _zip5 {
    my($v) = @_;
    $v =~ s/^(\d{5}).*$/$1/;
    return $v;
}

1;
