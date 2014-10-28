# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionComment;
use strict;
use Bivio::Base 'Model.RealmBase';

b_use('ClassWrapper.TupleTag')->wrap_methods(__PACKAGE__,  {
    moniker => __PACKAGE__->TUPLE_TAG_PREFIX,
    primary_id_field => 'motion_comment_id',
});

sub TUPLE_TAG_PREFIX {
    return 'b_motion_comment';
}

sub get_tuple_use_moniker {
    my($self) = @_;
    return $self->req(qw(Model.MotionList TupleUse.moniker));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'motion_comment_t',
	columns => {
	    motion_comment_id => ['PrimaryId', 'PRIMARY_KEY'],
	    motion_id => ['Motion.motion_id', 'NOT_NULL'],
	    user_id => ['User.user_id', 'NOT_NULL'],
	    creation_date_time => ['DateTime', 'NOT_NULL'],
	    comment => ['Text64K', 'NOT_NULL'],
	},
    });
}

1;
