# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::CIDRNotation;
use strict;
use Bivio::Base 'Type.SyntacticString';
use Socket ();

my($_IDI) = __PACKAGE__->instance_data_index;
my($_TE) = b_use('Bivio.TypeError');
my($_N) = b_use('Type.Number');
my($_IPA) = b_use('Type.IPAddress');

#TODO: Only works with ipv4
sub REGEX {
    return qr{(@{[$_IPA->REGEX]})/(\d{1,2})}io;
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

sub get_net_mask {
    my($self) = @_;
    return $_IPA->from_inet(pack('N', $self->[$_IDI]->{mask}));
}

sub get_width {
    return 18;
}

sub assert_host_address {
    my($self, $ip) = @_;
    b_die($ip, ': not found in ', $self)
        unless @{$self->map_host_addresses(sub {$ip eq shift(@_) ? 1 : ()})};
    return $ip;
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
    my($last) = pack('N', $bits == 32 ? 0 : 0xffffffff >> $bits);
    my($inet) = pack('C4', split(/\./, $decimals));
    return (undef, $_TE->NOT_FOUND)
        unless unpack('N', $last & $inet) == 0;
    return _new(
        $proto,
        unpack('N', $inet),
        unpack('N', $last),
        $_IPA->from_inet($inet) . "/$bits",
        $bits,
        0xffffffff - unpack('N', $last),
    );
}

sub map_host_addresses {
    my($self, $op) = @_;
    my($fields) = $self->[$_IDI];
    my($n) = $fields->{min_number};
    return [map(
        $op->(
            $_IPA->from_inet(pack('N', $_N->add($n, $_, 0))),
        ),
        0 .. $fields->{last},
    )];
}

sub to_literal {
    my($proto, $value) = @_;
    return $value ? $value->as_string : undef;
}

sub _new {
    my($proto, $number, $last, $string, $bits, $mask) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {
        min_number => $number,
        last => $last,
        string => $string,
        bits => $bits,
        mask => $mask,
    };
    return $self;
}

1;
