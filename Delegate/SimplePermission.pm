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
#20-29 free (if implemented)
	FEATURE_CRM => [30],
	FEATURE_MOTION => [31],
	FEATURE_TUPLE => [32],
	# Temporary value for upgrades
	FEATURE_PERMISSIONS51 => [49],
	LAST_RESERVED_VALUE => [50],
    ];
}

1;
