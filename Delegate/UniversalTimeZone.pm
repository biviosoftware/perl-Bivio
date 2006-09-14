# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::UniversalTimeZone;
use strict;
use base 'Bivio::Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
	UNKNOWN => [0, "Unknown (UTC default)"],
    ];
}

1;
