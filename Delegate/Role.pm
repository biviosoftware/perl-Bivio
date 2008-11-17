# Copyright (c) 2005-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::Role;
use strict;
use Bivio::Base 'Bivio.Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
        UNKNOWN => 0,
	# user not supplied with request or unable to authenticate
        ANONYMOUS => 1,
	# privileges of any authenticated user, not particular to real
        USER => 2,
        WITHDRAWN => 3,
        GUEST => 4,
        MEMBER => 5,
        ACCOUNTANT => 6,
        ADMINISTRATOR => 7,
	MAIL_RECIPIENT => 8,
	FILE_WRITER => 9,
	UNCONFIRMED_EMAIL => 10,
	UNAPPROVED_APPLICANT => 11,
#        LAST_RESERVED => 19,
    ];
}

sub is_admin {
    return shift->equals_by_name('ADMINISTRATOR');
}

1;
