# Copyright (c) 2007-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::RowTagKey;
use strict;
use Bivio::Base 'Type.EnumDelegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
        UNKNOWN => 0,
	ERROR_DETAIL => [1, 'Text'],
	RELATED_ID => [2, 'PrimaryId'],
	DEFAULT_TUPLE_MONIKER => [3, 'TupleMoniker'],
	MAIL_SUBJECT_PREFIX => [4, 'MailSubject'],
	BULLETIN_MAIL_MODE => [5, 'BulletinMailMode'],
#6
	PAGE_SIZE => [7, 'PageSize'],
	CANONICAL_EMAIL_ALIAS => [8, 'Email'],
	CANONICAL_SENDER_EMAIL => [9, 'Email'],
	CRM_SUBJECT_PREFIX => [10, 'MailSubject'],
#11
	TEXTAREA_WRAP_LINES => [12, 'BooleanFalseDefault'],
	TIME_ZONE => [13, 'TimeZone'],
	MAIL_WANT_REPLY_TO => [14, 'MailWantReplyTo'],
	MAIL_VISIBILITY => [15, 'MailVisibility'],
	BULLETIN_BODY_TEMPLATE => [16, 'BulletinBodyTemplate'],
	LAST_RESERVED_VALUE => 99,
    ];
}

1;
