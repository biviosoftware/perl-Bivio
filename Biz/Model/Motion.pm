# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::Motion;
use strict;
use base 'Bivio::Biz::PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create {
    my($self, $values) = @_;
    $values->{realm_id} = $self->get_request->get('auth_id');
    $values->{name_lc} = lc($values->{name});
    return $self->SUPER::create($values);
}

sub update {
    my($self, $values) = @_;
    $values->{name_lc} = lc($values->{name});
    return $self->SUPER::update($values);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'motion_t',
        columns => {
            motion_id => ['PrimaryId', 'PRIMARY_KEY'],
	    realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
	    name => ['Line', 'NOT_NULL'],
	    name_lc => ['Line', 'NOT_NULL'],
	    question => ['Text', 'NOT_NULL'],
	    status => ['MotionStatus', 'NOT_NULL'],
	    type => ['MotionType', 'NOT_NULL'],
	},
	auth_id => 'realm_id',
    });
}

1;
