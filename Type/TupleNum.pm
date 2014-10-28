# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TupleNum;
use strict;
use base 'Bivio::Type::Integer';


sub get_min {
    return 1;
}

1;
