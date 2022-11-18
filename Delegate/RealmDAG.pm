# Copyright (c) 2007-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::RealmDAG;
use strict;
use Bivio::Base 'Type.EnumDelegate';


sub get_delegate_info {
    return [
        UNKNOWN => 0,
        RECIPROCAL_RIGHTS => 1,
        GRAPH => 2,
        PARENT_IS_AUTHORIZED_ACCESS => 3,
        LAST_RESERVED_VALUE => 19,
    ];
}

1;
