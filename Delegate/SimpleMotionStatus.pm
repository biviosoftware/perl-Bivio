# Copyright (c) 2006-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::SimpleMotionStatus;
use strict;
use Bivio::Base 'Type.EnumDelegate';


sub get_delegate_info {
    return [
	UNKNOWN => [0],
	OPEN => [1],
	CLOSED => [2],
    ];
}

1;
