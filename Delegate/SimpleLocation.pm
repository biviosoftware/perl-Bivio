# Copyright (c) 2002-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::SimpleLocation;
use strict;
use Bivio::Base 'Bivio::Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    # Returns HOME.
    return [
	HOME => [1],
	WORK => [2],
	MOBILE => [3],
    ];
}

1;
