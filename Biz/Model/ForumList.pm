# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [['RealmOwner.realm_id', 'Forum.forum_id']],
	order_by => [
	    {
		name => 'RealmOwner.name',
		type => 'ForumName',
	    },
	    'RealmOwner.display_name',
	],
	other => [
	    'Forum.is_public_email',
	    'Forum.want_reply_to',
	],
	auth_id => ['Forum.parent_realm_id'],
    });
}

1;
