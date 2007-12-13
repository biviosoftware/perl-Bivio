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
    return shift->SRID_WGS84;
}

sub SRID_WGS84 {
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
	    sub {return (lc($_[0]), _convert($self, @_))},
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
    return qq{GeomFromEWKT($place_holder)};
}

sub internal_set_srid {
    my($self, $srid) = @_;
    $self->[$_IDI]->{srid} = $srid;
    return $self;
}

sub _convert {
    my($self, $which, $value) = @_;
    return defined($value) ? uc($value) : $self->$which();
}

1;
