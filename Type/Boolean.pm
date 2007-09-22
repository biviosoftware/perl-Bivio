# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Boolean;
use strict;
use Bivio::Base 'Bivio::Type::Integer';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub FALSE {
    return 0;
}

sub TRUE {
    return 1;
}

sub can_be_negative {
    return 0;
}

sub can_be_positive {
    return 1;
}

sub can_be_zero {
    return 1;
}

sub from_literal {
    my($res, $err) = shift->SUPER::from_literal(@_);
    # Booleans are never non-null.  Always returns 0 or 1 or error.
    return defined($res) ? $res : $err ? ($res, $err) : 0;
}

sub get_decimals {
    return 0;
}

sub get_default {
    return 0;
}

sub get_max {
    return 1;
}

sub get_min {
    return 0;
}

sub get_precision {
    return 1;
}

sub get_width {
    return 1;
}

sub to_sql_param {
    shift;
    my($v) = shift;
    return !defined($v) ? undef : $v ? '1' : '0';
}

sub to_xml {
    my($proto, $value) = @_;
    return !defined($value) ? '' : $value ? 'true' : 'false';
}

1;
