# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AdmRealmRoleList;
use strict;
use Bivio::Base 'Biz.ListModel';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        can_iterate => 1,
        primary_key => [[qw(RealmRole.realm_id RealmOwner.realm_id)]],
        order_by => [qw(RealmRole.realm_id)],
        other => [qw(
            RealmRole.role
            RealmRole.permission_set
            RealmOwner.realm_type
            RealmOwner.name
            RealmOwner.display_name
        )],
    });
}

1;
