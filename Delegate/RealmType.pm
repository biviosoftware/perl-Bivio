# Copyright (c) 2005-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::RealmType;
use strict;
use Bivio::Base 'Type.EnumDelegate';


sub get_delegate_info {
    return [
        ANY_OWNER => 0,
        GENERAL => 1,
        USER => 2,
        CLUB => 3,
        FORUM => 4,
        CALENDAR_EVENT => 5,
        # START at 21
    ];
}

1;
