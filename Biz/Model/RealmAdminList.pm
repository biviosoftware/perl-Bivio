# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmAdminList;
use strict;
use base 'Bivio::Biz::Model::RealmUserList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_get_roles {
    return [Bivio::Auth::Role->ADMINISTRATOR];
}

1;
