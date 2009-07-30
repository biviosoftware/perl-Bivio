# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UnapprovedApplicantList;
use strict;
use Bivio::Base 'Model.GroupUserList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = b_use('Auth.Role');

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->SUPER::internal_initialize;
    my(@order) = 'RealmOwner.creation_date_time';
    push(@order, @{$info->{order_by}});
    delete($info->{order_by});
    return $self->merge_initialize_info($info, {
 	order_by => [@order],
    });
}

sub internal_qualify_role {
    my($self, $stmt) = @_;
    $stmt->where($stmt->EQ('RealmUser.role', [$_R->UNAPPROVED_APPLICANT]));
    return;
}

1;
