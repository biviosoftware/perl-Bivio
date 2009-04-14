# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::RowTagKey;
use strict;
use Bivio::Base 'Bivio.Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
        UNKNOWN => 0,
	ERROR_DETAIL => 1,
	RELATED_ID => 2,
	DEFAULT_TUPLE_MONIKER => 3,
	MAIL_SUBJECT_PREFIX => 4,
	BULLETIN_MAIL_MODE => 5,
	REALM_FILE_LOCKING => 6,
	PAGE_SIZE => 7,
	CANONICAL_EMAIL_ALIAS => 8,
	CANONICAL_SENDER_EMAIL => 9,
	CRM_SUBJECT_PREFIX => 10,
	FACADE_CHILD_TYPE => 11,
	TEXTAREA_WRAP_LINES => 12,
	TIME_ZONE => 13,
	LAST_RESERVED_VALUE => 99,
    ];
}

1;
