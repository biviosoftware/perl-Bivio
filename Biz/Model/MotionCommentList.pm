# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionCommentList;
use strict;
use Bivio::Base 'Biz.ListModel';

b_use('ClassWrapper.TupleTag')->wrap_methods(
    __PACKAGE__, b_use('Model.MotionCommentForm')->TUPLE_TAG_INFO);

sub MAX_TRIMMED_COMMENT_SIZE {
    return 32;
}

sub get_tuple_use_moniker {
    my($self) = @_;
    my($motion) = $self->req('Model.Motion');
    return $motion->get('tuple_def_id')
	? $self->new_other('TupleUse')->load({
	    tuple_def_id => $motion->get('tuple_def_id'),
	})->get('moniker')
	: undef;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        can_iterate => 1,
	parent_id => 'MotionComment.motion_id',
	primary_key => ['MotionComment.motion_comment_id'],
	order_by => [
	    'MotionComment.motion_comment_id',
	    'MotionComment.comment',
	    'RealmOwner.display_name',
	    'MotionComment.creation_date_time',
	],
	other => [
	    [qw(MotionComment.user_id RealmOwner.realm_id)],
	    {
		name => 'comment_trimmed',
		type => 'String',
		contraint => 'NONE',
	    }
	],
	auth_id => ['MotionComment.realm_id'],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    my($comment) =  $row->{'MotionComment.comment'};
    if (length($comment) > $self->MAX_TRIMMED_COMMENT_SIZE) {
	my($ellipses) = '...';
	$comment = substr($comment, 0, MAX_TRIMMED_COMMENT_SIZE - length($ellipses));
	$comment =~ s/\s*$/$ellipses/;
    }
    $row->{comment_trimmed} = $comment;
    return 1;
}

1;
