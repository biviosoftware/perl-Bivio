# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::PageSize;
use strict;
use Bivio::Base 'Type.Integer';


sub ROW_TAG_KEY {
    return 'PAGE_SIZE';
}

sub get_default {
    return 15;
}

sub get_max {
    return 2000;
}

sub get_min {
    return 5;
}

1;
