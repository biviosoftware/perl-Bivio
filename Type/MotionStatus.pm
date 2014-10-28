# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::MotionStatus;
use strict;
use base 'Bivio::Type::EnumDelegator';


__PACKAGE__->compile;

sub is_continuous {
    return 0;
}

1;
