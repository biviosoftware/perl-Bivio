# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::RealmType;
use strict;
use Bivio::Base 'Bivio.Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
	ANY_OWNER => 0,
	GENERAL => 1,
	USER => 2,
	CLUB => 3,
	FORUM => 4,
	CALENDAR_EVENT=> 5,
    ];
}

1;
