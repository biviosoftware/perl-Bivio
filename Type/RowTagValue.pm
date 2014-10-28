# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::RowTagValue;
use strict;
use Bivio::Base 'Type.String';


sub get_width {
    return b_use('Type.Text64K')->get_width;
}

1;
