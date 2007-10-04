# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::RealmDAG;
use strict;
use Bivio::Base 'Bivio::Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
	UNKNOWN => [0],
    ];
}

1;
