# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserRealmDAVList;
use strict;
use Bivio::Base 'Model.RealmDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	other => [
	    ['RealmOwner.realm_id', 'RealmUser.realm_id'],
	    {
		name => 'RealmUser.role',
		in_select => 0,
	    },
	],
    });
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    my($req) = $self->get_request;
    $stmt->where(
	$stmt->EQ('RealmUser.user_id', [$req->get('auth_user_id')]),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
