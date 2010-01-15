# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AuthUserGroupList;
use strict;
use Bivio::Base 'Model.AuthUserRealmList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    return $row->{'RealmOwner.realm_type'}->is_group;
}

1;
