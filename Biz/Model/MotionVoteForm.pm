# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionVoteForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty {
    my($self) = @_;
    $self->load_from_model_properties('Motion');
    return;
}

sub execute_ok {
    my($self) = @_;
    shift->SUPER::execute_ok(@_);
    return if $self->in_error;
    $self->new_other('MotionVote')->create({
	%{$self->get_model_properties('MotionVote')},
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
	visible => [
	    'MotionVote.vote',
	    'MotionVote.comment',
	],
	other => [
	    [qw(Motion.motion_id MotionVote.motion_id)],
	    'Motion.name',
	    'Motion.question',
	    'Motion.type',
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my($l) = $self->get_request->unsafe_get('Model.MotionList');
    $self->internal_put_field('Motion.motion_id' =>
				  $l->get('Motion.motion_id'))
	if $l && $l->unsafe_get('Motion.motion_id');
    return;
}

1;
