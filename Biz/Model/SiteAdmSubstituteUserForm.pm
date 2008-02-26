# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SiteAdmSubstituteUserForm;
use strict;
use Bivio::Base 'Model.AdmSubstituteUserForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub assert_can_substitute_user {
    return;
}

1;
