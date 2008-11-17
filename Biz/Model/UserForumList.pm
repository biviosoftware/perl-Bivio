# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserForumList;
use strict;
use Bivio::Base 'Model.UserRealmList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub LOAD_ALL_SIZE {
#TODO: Needs to be high to account for admins in all forums
    return 5000;
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

1;
