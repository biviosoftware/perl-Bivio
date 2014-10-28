# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::PositiveInteger;
use strict;
use Bivio::Base 'Type.Integer';


sub get_min {
    return 1;
}

1;
