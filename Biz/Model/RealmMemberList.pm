# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMemberList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_R) = b_use('Auth.Role');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	# Minimal on purpose: Simply qualifies MEMBER as an abstraction
	primary_key => ['RealmUser.user_id'],
	auth_id => 'RealmUser.realm_id',
    });
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    $stmt->where(['RealmUser.role', $_R->get_category_role_group('all_members')]);
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
