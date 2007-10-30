# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionVoteList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 0,
	parent_id => 'MotionVote.motion_id',
	primary_key => [qw(MotionVote.motion_id MotionVote.user_id)],
	order_by => [
 	    'MotionVote.creation_date_time',
	    'MotionVote.vote',
	    'MotionVote.comment',
	    'Email.email',
	],
	other => [
	    [qw(MotionVote.user_id Email.realm_id)],
	],
	auth_id => ['MotionVote.realm_id'],
    });
}

1;
