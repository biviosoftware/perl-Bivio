# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmAdminEmailList;
use strict;
use Bivio::Base 'Model.RealmEmailList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_get_roles {
    return [Bivio::Auth::Role->ADMINISTRATOR];
}

1;
