# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::CIDRNotation;
use strict;
use Bivio::Base 'Type.SyntacticString';
use Socket ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_TE) = b_use('Bivio.TypeError');
my($_N) = b_use('Type.Number');

#TODO: Only works with ipv4
sub REGEX {
    return qr{((?:\d{1,3}\.){3}(?:\d{1,3}))/(\d{1,2})}i;
}

sub address_to_host_num {
    my($self, $address) = @_;
    my($places) = int($self->[$_IDI]->{bits} / 8);
    $places = 3
	if $places > 3;
    $places = 4 - $places;
    my($res) = $address =~ /((?:\.\d+){$places})$/;
    b_die($address, ': invalid address')
	unless defined($res);
    return substr($res, 1);
}

sub as_string {
    my($self) = @_;
    return shift->SUPER::as_string(@_)
	unless ref($self);
    return $self->[$_IDI]->{string};
}

sub get_min_width {
    return 9;
}

sub get_width {
    return 18;
}

sub internal_post_from_literal {
    my($proto, $value) = @_;
    my($decimals, $bits) = $value =~ $proto->REGEX;
    return (undef, $_TE->NUMBER_RANGE)
	unless 8 <= $bits && $bits <= 32;
    $bits += 0;
    foreach my $i (split(/\./, $decimals)) {
	return (undef, $_TE->NUMBER_RANGE)
	    unless $i <= 255;
    }
    my($mask) = pack('N', $bits == 32 ? 0 : 0xffffffff >> $bits);
    my($inet) = pack('C4', split(/\./, $decimals));
    return (undef, $_TE->NOT_FOUND)
	unless unpack('N', $mask & $inet) == 0;
    my($n) = unpack('N', $inet);
    return _new(
	$proto,
	unpack('N', $inet),
	unpack('N', $mask),
	join('.', unpack('C4', $inet)) . "/$bits",
	$bits,
    );
}

sub map_host_addresses {
    my($self, $op) = @_;
    my($fields) = $self->[$_IDI];
    my($n) = $fields->{min_number};
    return [map(
	$op->(
	    join(
		'.',
		unpack(
		    'C4',
		    pack('N', $_N->add($n, $_, 0)),
		),
	    ),
	),
	0 .. $fields->{last},
    )];
}

sub to_literal {
    my($proto, $value) = @_;
    return $value ? $value->as_string : undef;
}

sub _new {
    my($proto, $number, $last, $string, $bits) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {
        min_number => $number,
	last => $last,
	string => $string,
	bits => $bits,
    };
    return $self;
}

1;
