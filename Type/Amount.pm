# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Amount;
use strict;
use Bivio::Base 'Bivio::Type::Number';

# C<Bivio::Type::Amount> is a number used for all "floating point"
# or "big integer"
# computations, e.g. currencies, shares, and trading volume.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub can_be_negative {
    # : boolean
    # Returns true.
    return 1;
}

sub can_be_positive {
    # : boolean
    # Returns true.
    return 1;
}

sub can_be_zero {
    # : boolean
    # Returns true.
    return 1;
}

sub get_decimals {
    # : int
    # Returns 6.
    return 6;
}

sub get_max {
    # : string
    # Returns '9999999999999.9999999'.
    return '9999999999999.999999';
}

sub get_min {
    # : string
    # Returns '-9999999999999.9999999'.
    return '-9999999999999.999999';
}

sub get_precision {
    # : int
    # Returns 20.
    return 20;
}

sub get_width {
    # : int
    # Returns 22 (includes decimal and sign).
    return 22;
}

1;
