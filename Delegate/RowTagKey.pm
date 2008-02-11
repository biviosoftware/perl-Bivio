# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::RowTagKey;
use strict;
use Bivio::Base 'Bivio::Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
        UNKNOWN => 0,
	ERROR_DETAIL => 1,
	RELATED_ID => 2,
	DEFAULT_TUPLE_MONIKER => 3,
	MAIL_SUBJECT_PREFIX => 4,
	LAST_RESERVED_VALUE => 99,
    ];
}

1;
