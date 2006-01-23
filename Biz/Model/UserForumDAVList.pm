# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserForumDAVList;
use strict;
use base 'Bivio::Biz::Model::UserBaseDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        auth_id => ['Forum.parent_realm_id'],
        other => [
	    [qw(RealmOwner.realm_id Forum.forum_id)],
	],
    });
}

1;
