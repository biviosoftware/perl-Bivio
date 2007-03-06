# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionVote;
use strict;
use base 'Bivio::Biz::PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create {
    my($self, $values) = @_;
    my($req) = $self->get_request;
    $values->{realm_id} = $req->get('auth_id');
    $values->{user_id} = $req->get('auth_user_id');
    $values->{affiliated_realm_id} = $values->{user_id}
	unless defined($values->{affiliated_realm_id});
    return $self->SUPER::create($values);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'motion_vote_t',
        columns => {
            motion_id => ['Motion.motion_id', 'PRIMARY_KEY'],
            user_id => ['User.user_id', 'PRIMARY_KEY'],
	    affiliated_realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
	    realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
	    vote => ['MotionVote', 'NOT_NULL'],
	},
	auth_id => 'realm_id',
    });
}

1;
