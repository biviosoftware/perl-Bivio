# Copyright (c) 1999-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::Year;
use strict;
use Bivio::Base 'Type.Integer';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = __PACKAGE__->use('Type.DateTime');

sub WINDOW_SIZE {
    return 20;
}

sub from_literal {
    my($proto) = @_;
    my($res, $err) = shift->SUPER::from_literal(@_);
    return $err ? ($res, $err) : $res
        unless $err && $err == Bivio::TypeError->NUMBER_RANGE;
    # Compute with no range check
    ($res, $err) = Bivio::Type::Integer->from_literal(@_);
    return ($res, $err)
	if $err;
    return (undef, Bivio::TypeError->NUMBER_RANGE)
	unless $res >= 0 && $res < 100;
    return $proto->SUPER::from_literal(
	$res + int($proto->now / 100) * 100
	- ($res <= $proto->now % 100 + $proto->WINDOW_SIZE ? 0 : 100),
    );
}

sub get_default {
    return shift->now;
}

sub get_max {
    return '9999';
}

sub get_min {
    return 100;
}

sub get_width {
    return 4;
}

sub now {
    return $_DT->now_as_year;
}

1;
