# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::CIDRNotation;
use strict;
use Bivio::Base 'Type.SyntacticString';
use Socket ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_TE) = b_use('Bivio.TypeError');

#TODO: Only works with ipv4
sub REGEX {
    return qr{((?:\d{1,3}\.){3}(?:\d{1,3}))/(\d{1,2})}i;
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
	join('.', unpack('C4', $inet)) . '/' . ($bits + 0),
    );
}

sub map_host_addresses {
    my($self, $op) = @_;
    my($fields) = $self->[$_IDI];
    return [map(
	$op->(join('.', unpack('C4', pack('N', $_)))),
	$fields->{min_number} .. $fields->{max_number},
    )];
}

sub to_literal {
    my($proto, $value) = @_;
    return $value ? $value->as_string : undef;
}

sub _new {
    my($proto, $number, $count, $string) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {
        min_number => $number,
	max_number => $number + $count,
	string => $string,
    };
    return $self;
}

1;
