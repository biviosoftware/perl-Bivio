# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::BooleanFalseDefault;
use strict;
use Bivio::Base 'Type.Boolean';


sub get_default {
    return 0;
}

1;
