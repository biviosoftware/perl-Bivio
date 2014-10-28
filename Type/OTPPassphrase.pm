# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::OTPPassphrase;
use strict;
use Bivio::Base 'Type.String';


sub get_width {
    # OPIE allows this length
    return 127;
}

1;
