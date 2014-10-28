# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::CalendarEventMonthDate;
use strict;
use Bivio::Base 'Type.DateTime';

my($_D) = b_use('Type.Date');

sub from_literal {
    my($proto) = shift;
    my($v, $e) = $proto->SUPER::from_literal(@_);
    unless ($v) {
	($v, $e) = $_D->from_literal(@_);
	return ($v, $e)
	    unless $v;
    }
    return (_set($proto, $v), undef);
}

sub get_default {
    my($proto) = @_;
    return _set($proto, $proto->now);
}

sub to_query_value {
    my($proto, $value) = @_;
    return $proto->to_string($proto->from_literal_or_die($value));
}

sub now {
    my($proto) = shift;
    return _set($proto, $proto->SUPER::now(@_));
}

sub to_literal {
    my(undef, $value) = @_;
    return ''
	unless $value;
    return $_D->to_string($_D->from_datetime($value));
}

sub to_string {
    return shift->to_literal(@_);
}

sub _set {
    my($proto, $value) = @_;
    return $proto->set_beginning_of_day($proto->set_beginning_of_month($value));
}

1;
