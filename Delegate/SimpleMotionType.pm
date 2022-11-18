# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::SimpleMotionType;
use strict;
use Bivio::Base 'Type.EnumDelegate';


sub get_delegate_info {
    return [
        UNKNOWN => [0],
        VOTE_PER_USER => [1, 'One vote per user'],
    ];
}

1;
