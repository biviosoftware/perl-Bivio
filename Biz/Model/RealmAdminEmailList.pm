# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmAdminEmailList;
use strict;
use Bivio::Base 'Model.RealmEmailList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_ADMINS) = b_use('Auth.Role')->get_category_role_group('all_admins');

sub internal_get_roles {
    return [@$_ADMINS];
}

1;
