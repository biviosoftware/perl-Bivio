# Copyright (c) 2005-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::Role;
use strict;
use Bivio::Base 'Type.EnumDelegate';

my($_R) = b_use('Auth.Role');

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
    return {
        nobody => [],
        all_admins => [qw(ACCOUNTANT ADMINISTRATOR)],
        all_members => [qw(all_admins MEMBER)],
        all_guests => [qw(all_members GUEST)],
        all_users => [qw(all_guests WITHDRAWN UNAPPROVED_APPLICANT USER)],
        everybody => [qw(all_users ANONYMOUS)],
    };
}

1;
