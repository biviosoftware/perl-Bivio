# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::OTPSequence;
use strict;
use Bivio::Base 'Type.Integer';


sub get_max {
    return 499;
}

sub get_min {
    return 1;
}

1;
