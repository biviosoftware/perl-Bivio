# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TupleSlotArray;
use strict;
use Bivio::Base 'Type.StringArray';


sub get_width {
    return 0xffff;
}

1;
