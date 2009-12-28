# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::Role;
use strict;
use Bivio::Base 'Bivio.Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = b_use('Auth.Role');
my($_MAP) = {
    nobody => [],
    all_admins => [qw(ACCOUNTANT ADMINISTRATOR)],
    all_members => [qw(all_admins MEMBER)],
    all_users => [qw(all_members GUEST UNAPPROVED_APPLICANT USER WITHDRAWN)],
    everybody => [qw(all_users ANONYMOUS)],
};

sub get_application_specific_list {
    return grep($_->as_int > 19, $_R->get_non_zero_list);
}

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
	UNAPPROVED_APPLICANT => 10,
#        LAST_RESERVED => 19,
    ];
}

sub get_main_list {
     return map($_R->unsafe_from_name($_) ? $_R->$_() : (), qw(
	ADMINISTRATOR
	ACCOUNTANT
	MEMBER
	GUEST
	WITHDRAWN
    ));
}

sub internal_category_role_group_map {
    return $_MAP;
}

sub is_admin {
    return shift->eq_administrator;
}

1;
