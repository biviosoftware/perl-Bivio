# Copyright (c) 2010 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMUserList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_ROLE) = b_use('Auth.Role')->MAIL_RECIPIENT;


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        can_iterate => 1,
        primary_key => [
            [qw(RealmUser.user_id RealmOwner.realm_id)],
        ],
        order_by => [qw(
            RealmOwner.name
        )],
        other => [
            ['RealmUser.role', [$_ROLE]],
        ],
        auth_id => ['RealmUser.realm_id'],
    });
}

1;
