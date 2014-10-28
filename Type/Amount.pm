# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Amount;
use strict;
use Bivio::Base 'Type.Number';


sub can_be_negative {
    return 1;
}

sub can_be_positive {
    return 1;
}

sub can_be_zero {
    return 1;
}

sub get_decimals {
    return 6;
}

sub get_max {
    return '9999999999999.999999';
}

sub get_min {
    return '-9999999999999.999999';
}

sub get_precision {
    return 20;
}

sub get_width {
    return 22;
}

1;
