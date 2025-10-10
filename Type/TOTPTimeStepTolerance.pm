# Copyright (c) 2025 bivio, Inc.  All rights reserved.
package Bivio::Type::TOTPTimeStepTolerance;
use strict;
use Bivio::Base 'Type.Integer';

sub get_min {
    return 0;
}

sub get_max {
    return 3;
}

1;
