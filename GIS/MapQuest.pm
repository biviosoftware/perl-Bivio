# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::GIS::MapQuest;
use strict;
use Bivio::Base 'Collection.Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_AUTH_KEYS) = [qw(ClientId Password)];
my($_C) = __PACKAGE__->use('IO.Config');
$_C->register(my $_CFG = {
    map(($_ => $_C->REQUIRED), @$_AUTH_KEYS, 'referer'),
    access => 'dev',
});
my($_S) = __PACKAGE__->use('HTML.Scraper');
my($_HTML) = __PACKAGE__->use('Bivio.HTML');
my($_Z9) = __PACKAGE__->use('Type.USZipCode9');
my($_AUTH);
my($_SERVER) = {
    'Geocode#1' => 'geocode',
};

sub geocode_to_xml {
    my($self, $address_or_zip) = @_;
    my($z) = $_Z9->from_literal($address_or_zip);
    $address_or_zip = {PostalCode => $z}
	if $z;
    return $self->http_get(
	'Geocode#1' => ref($address_or_zip) ? {Address => $address_or_zip}
	    : {SingleLineAddress => {Address => $address_or_zip}},
    );
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    $_AUTH = {'Authentication#2' => {map(($_ => $_CFG->{$_}), @$_AUTH_KEYS)}};
    return;
}

sub http_get {
    my($self, $type, $attrs) = @_;
    my($s) = $_S->new({referer => $_CFG->{referer}});
    return ${$s->extract_content(
	$s->http_get(
	    qq{http://$_SERVER->{$type}.$_CFG->{access}.mapquest.com/mq/mqserver.dll?e=5&}
	    . $_HTML->escape_query(
		'<?xml version="1.0" encoding="ISO-8859-1"?>'
		. $self->to_xml({$type => [$attrs, $_AUTH]}),
	    ),
	),
    )};
}

sub to_xml {
    my($self, $value) = @_;
    return !ref($value) ? $value
	: join('',
	    ref($value) eq 'ARRAY' ? map($self->to_xml($_), @$value)
		: map({
		    my($k, $vn) = split(/#/, $_, 2);
		    (defined($vn) ? qq{<$k Version="$vn">} : "<$k>")
			. $self->to_xml($value->{$_}) . "</$k>";
		} sort(keys(%$value))),
        );
}

1;
