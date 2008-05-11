# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmAdminList;
use strict;
use Bivio::Base 'Model.RealmUserList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_ADMIN) = __PACKAGE__->use('Auth.Role')->ADMINISTRATOR;

sub internal_get_roles {
    return [$_ADMIN];
}

1;
