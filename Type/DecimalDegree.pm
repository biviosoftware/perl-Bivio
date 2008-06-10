# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::DecimalDegree;
use strict;
use Bivio::Base 'Type.Number';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_decimals {
    return 6;
}

sub get_min {
    return -180;
}

sub get_max {
    return 180;
}

sub get_precision {
    return 9;
}

sub get_width {
    return 11;
}

1;
