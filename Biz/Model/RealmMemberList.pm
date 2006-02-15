# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMemberList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
    $stmt->where(['RealmUser.role', [Bivio::Auth::Role->MEMBER]]);
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
