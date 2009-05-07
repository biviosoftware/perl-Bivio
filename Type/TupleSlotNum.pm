# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TupleSlotNum;
use strict;
use Bivio::Base 'Type.Integer';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_max {
    return 20;
}

sub get_min {
    return 1;
}

sub map_list {
    my($proto, $op) = @_;
    return [map(
	$op->($proto->field_name($_), $_),
	$proto->get_min .. $proto->get_max,
    )];
}

sub field_name {
    my(undef, $num) = @_;
    return "slot$num";
}

sub field_name_to_num {
    my(undef, $field) = @_;
    my($i) = $field =~ /\.slot(\d+)$/;
    die($field, ': not a slot')
	unless defined($i);
    return $i;
}

sub is_field_name {
    my(undef, $name) = @_;
    return $name =~ /(?:^|\.)slot\d+$/ ? 1 : 0;
}

1;
