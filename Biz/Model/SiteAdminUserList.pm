# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SiteAdminUserList;
use strict;
use Bivio::Base 'Model.AdmUserList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub SUBSTITUTE_USER_FORM {
    return 'SiteAdminSubstituteUserForm';
}

1;
