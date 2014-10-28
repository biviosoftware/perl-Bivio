# Copyright (c) 2002-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::SimpleLocation;
use strict;
use Bivio::Base 'Type.EnumDelegate';


sub get_delegate_info {
    return [
	HOME => [1],
	WORK => [2],
	MOBILE => [3],
	# START at 21
    ];
}

1;
