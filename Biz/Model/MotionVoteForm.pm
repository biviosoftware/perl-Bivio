# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionVoteForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub execute_empty {
    my($self) = @_;
    my($m) = $self->unsafe_get_model('MotionVote');
    $self->load_from_model_properties($m)
        if $m->is_loaded;
    return;
}

sub execute_ok {
    my($self) = @_;
    my($res) = shift->SUPER::execute_ok(@_);
    return $res unless $self->req('Model.MotionList')->can_vote;
    $self->create_or_update_model_properties('MotionVote');
    return $res;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
        visible => [qw(
            MotionVote.vote
            MotionVote.comment
        )],
        other => [
            'MotionVote.motion_id',
        ],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->internal_put_field('MotionVote.motion_id' =>
        $self->req(qw(Model.MotionList Motion.motion_id)));
    $self->internal_put_field('MotionVote.user_id' =>
        $self->req('auth_user_id'));
    return;
}

1;
