# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserForumList;
use strict;
use Bivio::Base 'Model.UserRealmList';

my($_REQUIRED_ROLE_GROUP)
    = b_use('Auth.Role')->get_category_role_group('all_guests');

sub LOAD_ALL_SIZE {
#TODO: Needs to be high to account for admins in all forums
    return 5000;
}

sub REQUIRED_ROLE_GROUP {
    return [@$_REQUIRED_ROLE_GROUP];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	order_by => [qw(
	    RealmOwner.name
            RealmOwner.display_name
        )],
	other => [
	    [qw(RealmUser.realm_id Forum.forum_id)],
	    'Forum.parent_realm_id',
	],
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where($stmt->IN('RealmUser.role', $self->REQUIRED_ROLE_GROUP));
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
