# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumList;
use strict;
use Bivio::Base 'Biz.ListModel';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	primary_key => [['Forum.forum_id', 'RealmOwner.realm_id']],
	order_by => [
	    {
		name => 'RealmOwner.name',
		type => 'ForumName',
	    },
	    'RealmOwner.display_name',
	],
	other => [
	    'Forum.require_otp',
	],
	auth_id => ['Forum.parent_realm_id'],
    });
}

1;
