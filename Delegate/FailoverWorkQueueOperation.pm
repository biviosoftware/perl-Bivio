# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::FailoverWorkQueueOperation;
use strict;
use Bivio::Base 'Type.EnumDelegate';


sub get_delegate_info {
    return [
        UNKNOWN => [0],
        DELETE_FILE => [1],
        CREATE_FILE => [2],
    ];
}

1;
