# Copyright (c) 2002-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::ECService;
use strict;
use Bivio::Base 'Type.EnumDelegate';


sub get_delegate_info {
    return [
	UNKNOWN => [0],
    ];
}

1;
