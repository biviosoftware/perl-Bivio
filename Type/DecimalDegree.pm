# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::DecimalDegree;
use strict;
use Bivio::Base 'Type.Number';


sub get_decimals {
    return 8;
}

sub get_min {
    return -180;
}

sub get_max {
    return 180;
}

sub get_precision {
    return 11;
}

sub get_width {
    return 13;
}

1;
