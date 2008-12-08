# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UnapprovedApplicantForm;
use strict;
use Bivio::Base 'Model.GroupUserForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USER_LIST_CLASS {
    return 'UnapprovedApplicantList';
}

sub internal_select_roles {
    return ['UNAPPROVED_APPLICANT', @{shift->SUPER::internal_select_roles(@_)}];
}

1;
