# Copyright (c) 2008-2023 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserSubscriptionList;
use strict;
use Bivio::Base 'Model.AuthUserGroupList';
b_use('IO.ClassLoaderAUTOLOAD');

my($_R) = b_use('Auth.Role');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        order_by => [qw(
            RealmOwner.display_name
        )],
        other => [
            'UserRealmSubscription.is_subscribed',
            [qw(RealmUser.realm_id UserRealmSubscription.realm_id(+))],
            [qw(RealmUser.user_id UserRealmSubscription.user_id(+))],
        ],
        group_by => [qw(
            RealmOwner.display_name
            RealmOwner.name
            RealmOwner.password
            RealmOwner.realm_type
            RealmOwner.creation_date_time
            RealmOwner.login_failure_count
            RealmUser.realm_id
            RealmUser.user_id
            RealmUser.role
            RealmUser.creation_date_time
            UserRealmSubscription.is_subscribed
        )],
    });
}

sub internal_qualifying_roles {
    return $_R->get_category_role_group('all_members');
}

sub load_all_qualified_realms {
#TODO: this isn't quite the right task to ask for...
    return shift->load_all_for_task('FORUM_MAIL_THREAD_ROOT_LIST');
}

1;
