# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserForumDAVList;
use strict;
use Bivio::Base 'Model.UserBaseDAVList';

my($_REQUIRED_ROLE_GROUP) = b_use('Model.UserForumList')
    ->REQUIRED_ROLE_GROUP;

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        auth_id => ['Forum.parent_realm_id'],
        other => [
            [qw(RealmOwner.realm_id Forum.forum_id)],
        ],
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where($stmt->IN('RealmUser.role', $_REQUIRED_ROLE_GROUP));
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
