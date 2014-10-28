# Copyright (c) 2006-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::SimpleMotionVote;
use strict;
use Bivio::Base 'Type.EnumDelegate';


sub get_delegate_info {
    return [
	UNKNOWN => [0],
	YES => [1],
	NO => [2],
	ABSTAIN => [3],
    ];
}

1;
