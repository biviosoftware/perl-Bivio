# Copyright (c) 2025 bivio, Inc.  All rights reserved.
package Bivio::Type::TOTPPeriod;
use strict;
use Bivio::Base 'Type.Integer';

sub get_min {
    return 30;
}

sub get_max {
    return 90;
}

1;
