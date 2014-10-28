# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::USZipCode5;
use strict;
use Bivio::Base 'Type.USZipCode';


sub get_min_width {
    return 5;
}

sub get_width {
    return 5;
}

1;
