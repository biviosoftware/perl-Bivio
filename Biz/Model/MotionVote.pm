# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionVote;
use strict;
use Bivio::Base 'Model.RealmBase';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'motion_vote_t',
        columns => {
            motion_id => ['Motion.motion_id', 'PRIMARY_KEY'],
            user_id => ['User.user_id', 'PRIMARY_KEY'],
            affiliated_realm_id => ['RealmOwner.realm_id', 'NONE'],
            vote => ['MotionVote', 'NOT_NULL'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
            comment => ['Text64K', 'NONE'],
        },
    });
}

1;
