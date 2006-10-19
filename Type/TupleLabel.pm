# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TupleLabel;
use strict;
use base 'Bivio::Type::Line';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REGEX {
    return qr{[a-z][-\w]+}i;
}

sub compare_defined {
    my(undef, $left, $right) = @_;
    return lc($left) cmp lc($right);
}

sub from_literal {
    my($proto) = shift;
    my($v, $e) = $proto->SUPER::from_literal(@_);
    return !defined($v) ? ($v, $e)
	: $v =~ /^@{[$proto->REGEX]}$/ ? $v
	: (undef, Bivio::TypeError->TUPLE_LABEL);
}

1;
