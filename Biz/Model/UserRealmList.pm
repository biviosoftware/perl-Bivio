# Copyright (c) 1999-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserRealmList;
use strict;
use Bivio::Base 'Model.RoleBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub find_row_by_type {
    return shift->find_row_by('RealmOwner.realm_type', shift);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	order_by => [qw(
	    RealmOwner.name
	)],
	other => [qw(
	    RealmOwner.realm_type
            RealmOwner.display_name
	)],
	primary_key => [
	    [qw(RealmUser.realm_id RealmOwner.realm_id)],
	],
	auth_id => ['RealmUser.user_id'],
    });
}

1;
