# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::Geom;
use strict;
use Bivio::Base 'Bivio::Type';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TE) = __PACKAGE__->use('Bivio::TypeError');
my($_IDI) = __PACKAGE__->instance_data_index;

sub SRID {
    # WGS84; WGS_1984; WGS 84
    return 4326;
}

sub as_string {
    my($self) = @_;
    return $self->to_sql_param($self);
}

sub from_literal {
    my($proto, $value) = @_;
    return (undef, undef)
	unless $value;
    my($srid, $type, $wkt) = $value =~ /^SRID=(\d+);([a-z]+)\((.+)\)$/is;
    return (undef, $_TE->SYNTAX_ERROR)
        unless $srid;
    my($e) = $proto->validate_wkt($wkt);
    return (undef, $e)
	if $e;
    return (undef, $_TE->NOT_FOUND)
        unless $proto->SRID eq $srid;
    return (undef, $_TE->UNSUPPORTED_TYPE)
        unless $proto->TYPE eq $type;
    return $proto->new($wkt, $type, $srid);
}

sub from_sql_column {
    return shift->from_literal_or_die(shift, 1);
}

sub from_sql_value {
    my(undef, $place_holder) = @_;
    return qq{asEWKT($place_holder)};
}

sub new {
    my($proto, $wkt, $type, $srid) = @_;
    return undef
	unless defined($wkt);
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {
	@{$self->map_together(
	    sub {(lc($_[0]),_assert($self, @_))},
	    [qw(TYPE SRID)],
	    [$type, $srid],
	)},
	wkt => $wkt,
    };
    return $self;
}

sub to_sql_param {
    my($proto, $value) = @_;
    return undef
	unless $value;
    my($fields) = $value->[$_IDI];
    return 'SRID=' . $fields->{srid} . ';' . $fields->{type}
	. '(' . $fields->{wkt} . ')';
}

sub to_sql_value {
    my($proto, $place_holder) = @_;
    $place_holder ||= '?';
    return qq{GeoFromEWKT($place_holder)};
}

sub _assert {
    my($self, $which, $value) = @_;
    my($exp) = $self->$which();
    return $exp
	unless defined($value);
    $value = uc($value);
    Bivio::Die->die($value, ": expecting $which=", $exp)
        unless $exp eq $value;
    return $value;
}

1;
