# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AuthUserGroupList;
use strict;
use Bivio::Base 'Model.AuthUserRealmList';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	other => [
	    ['RealmOwner.realm_type',
	     [b_use('Auth.RealmType')->get_any_group_list]],
	],
    });
}

1;
