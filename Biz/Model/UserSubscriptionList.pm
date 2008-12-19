# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserSubscriptionList;
use strict;
use Bivio::Base 'Model.UserRealmList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = b_use('Auth.Role');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        order_by => [qw(
	    RealmOwner.display_name
        )],
	other => [
	    ['RealmOwner.realm_type',
	     [b_use('Auth.RealmType')->get_any_group_list]],
	],
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    return shift->SUPER::internal_prepare_statement(@_);
}

sub internal_qualifying_roles {
    return [map($_R->$_(), qw(MEMBER ACCOUNTANT ADMINISTRATOR))];
}

1;
