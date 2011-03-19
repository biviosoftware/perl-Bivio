# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionVoteForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_MV) = b_use('Type.MotionVote');

sub execute_empty {
    my($self) = @_;
    $self->load_from_model_properties('Motion');
    $self->internal_put_field("MotionVote.user_id" => $self->req('auth_user_id'));
    my($m) = $self->unsafe_get_model('MotionVote');
    if ($m->is_loaded) {
	$self->load_from_model_properties($m);
    } else {
	$self->internal_put_field("MotionVote.vote" => $_MV->ABSTAIN);
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    return unless $self->req('Model.MotionList')->can_vote;
    $self->internal_put_field("MotionVote.user_id" => $self->req('auth_user_id'));
    $self->create_or_update_model_properties('MotionVote');
    return;
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
	    [qw(Motion.motion_id MotionVote.motion_id)],
	    qw(
	        Motion.name
		Motion.question
		Motion.type
	    ),
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->internal_put_field('Motion.motion_id' =>
        $self->req(qw(Model.MotionList Motion.motion_id)));
    return;
}

sub _is_create {
    return shift->get('form_mode')->eq_create;
}

sub _is_edit {
    return shift->get('form_mode')->eq_edit;
}

1;
