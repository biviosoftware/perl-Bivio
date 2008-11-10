# Copyright (c) 2001-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::SimplePermission;
use strict;
use base 'Bivio::Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
	ANYBODY => [1],
	ANY_USER => [2],
	DATA_READ => [3],
	DATA_WRITE => [4],
	ADMIN_READ => [5],
	ADMIN_WRITE => [6],
	SUBSTITUTE_USER_TRANSIENT => [7],
	SUPER_USER_TRANSIENT => [8],
	TEST_TRANSIENT => [9],
	MAIL_READ => [10],
	MAIL_WRITE => [11],
	MAIL_SEND => [12],
	MAIL_POST => [13],
	TUPLE_READ => [14],
	TUPLE_WRITE => [15],
	TUPLE_ADMIN => [16],
	MOTION_READ => [17],
	MOTION_WRITE => [18],
	MOTION_ADMIN => [19],
	FEATURE_SITE_ADM => [20],
	FEATURE_FILE => [21],
	FEATURE_BLOG => [22],
	FEATURE_WIKI => [23],
	FEATURE_DAV => [24],
	FEATURE_MAIL => [25],
	FEATURE_CALENDAR => [26],
	FEATURE_CRM => [27],
	FEATURE_MOTION => [28],
	FEATURE_TUPLE => [29],
	LAST_RESERVED_VALUE => [50],
    ];
}

1;
