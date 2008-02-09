# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmUserList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_get_roles {
    return [];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	order_by => [qw(
            RealmUser.role
            RealmOwner.display_name
        )],
	primary_key => [
	    [qw(RealmUser.user_id RealmOwner.realm_id)],
	],
	other_query_keys => ['roles'],
	auth_id => ['RealmUser.realm_id'],
    });
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    my($r) = $query->unsafe_get('roles') || [];
    push(@$r, @{$self->internal_get_roles || []});
    $stmt->where($stmt->IN('RealmUser.role', $r))
	if @$r;
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
