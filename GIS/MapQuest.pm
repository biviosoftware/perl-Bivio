# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::GIS::MapQuest;
use strict;
use Bivio::Base 'Collection.Attributes';
use XML::Simple ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_AUTH_KEYS) = [qw(ClientId Password)];
my($_C) = __PACKAGE__->use('IO.Config');
$_C->register(my $_CFG = {
    map(($_ => $_C->REQUIRED), @$_AUTH_KEYS, 'Referer'),
    access => 'dev',
});
my($_S) = __PACKAGE__->use('HTML.Scraper');
my($_HTML) = __PACKAGE__->use('Bivio.HTML');
my($_Z9) = __PACKAGE__->use('Type.USZipCode9');
my($_AUTH);
my($_SERVER) = {
    'Geocode Version="1"' => 'geocode',
    'DoRoute Version="2"' => 'route',
};
my($_ROUTE_OPTIONS) = {
    FASTEST => [RouteType => 0],
    SHORTEST => [RouteType => 1],
    PEDESTRIAN => [RouteType => 2],
    OPTIMIZED => [RouteType => 3],
    DEFAULT => [NarrativeType => 0],
    HTML => [NarrativeType => 1],
    NONE => [NarrativeType => -1],
};

sub maneuvers_to_distance {
    my($self, $maneuvers) = @_;
    my($distance) = 0;
    foreach my $m (@$maneuvers) {
	$distance += $m->{Distance} || b_die($m, ': invalid maneuver');
    }
    return sprintf('%.2f', $distance);
}

sub geocode_to_address {
    my($res) = _from_xml(shift->geocode_to_xml(@_));
    return $res->{LocationCollection}->{GeoAddress}
	|| b_die($res, ': unexpected result');
}

sub geocode_to_xml {
    my($self, $address_or_zip) = @_;
    my($z) = $_Z9->from_literal($address_or_zip);
    $address_or_zip = {PostalCode => $z}
	if $z;
    my($res) = $self->http_get(
	'Geocode Version="1"'
	    => ref($address_or_zip) ? {Address => $address_or_zip}
	    : {SingleLineAddress => {Address => $address_or_zip}},
    );
    b_die(NOT_FOUND => {entity => $address_or_zip, result => $res})
	if $res =~ m{\Q<Lat>39.527596</Lat><Lng>-99.141968</Lng>\E};
    b_die(TOO_MANY => {entity => $address_or_zip, result => $res})
	unless $res =~ m{\QCount="1"\E};
    return $res;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    $_AUTH = {'Authentication Version="2"' => {map(($_ => $_CFG->{$_}), @$_AUTH_KEYS)}};
    return;
}

sub http_get {
    my($self, $type, $attrs) = @_;
    my($server) = $_SERVER->{$type} || b_die($type, ': unhandled type');
    my($s) = $_S->new({Referer => $_CFG->{Referer}});
    return ${$s->extract_content(
	$s->http_get(
	    qq{http://$server.$_CFG->{access}.mapquest.com/mq/mqserver.dll?e=5&}
	    . $_HTML->escape_query(
		'<?xml version="1.0" encoding="ISO-8859-1"?>'
		. $self->to_xml({$type => [$attrs, $_AUTH]}),
	    ),
	),
    )};
}

sub route_options {
    my($self, $options) = @_;
    return {
	RouteOptions => {map(
	    @{$_ROUTE_OPTIONS->{$_} || b_die($_, ': invalid')},
	    ref($options) ? @$options : $options ? $options : (),
	)},
    };
}

sub route_to_maneuvers {
    my($tr) = _from_xml(shift->route_to_xml(@_))->{RouteResults}->{TrekRoutes};
    b_die($tr, ': incorrect number of TrekRoutes')
	unless $tr->{Count} == 1;
    my($m) = $tr->{TrekRoute}->{Maneuvers}->{Maneuver};
    b_die($m, ': too few Maneuvers')
	unless @$m >= 1;
    return $m;
}

sub route_to_xml {
    my($self, $locations, $options) = @_;
    my($res) = $self->http_get(
	'DoRoute Version="2"' => [
	    {qq{LocationCollection Count="@{[scalar(@$locations)]}"} => [
		map(
		    {GeoAddress => $self->geocode_to_address($_)},
		    @$locations,
		),
	    ]},
 	    $self->route_options($options),
	],
    );
    b_die(CLIENT_ERROR => {entity => [$locations, $options], result => $res})
	unless $res =~ /\QResultCode>0<\E/;
    return $res;
}

sub to_xml {
    my($self, $value) = @_;
    return !ref($value) ? $value
	: join('',
	    ref($value) eq 'ARRAY' ? map($self->to_xml($_), @$value)
		: map({
		    my($k, $a) = split(/ /, $_, 2);
		    $a = $a ? " $a" : '';
		    qq{<$k$a>} . $self->to_xml($value->{$_}) . "</$k>";
		} sort(keys(%$value))),
        );
}

sub _from_xml {
    return XML::Simple::xml_in(@_);
}

1;
