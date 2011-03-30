# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionCommentForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MC) = b_use('Model.MotionComment');
my($_TAG_ID) = 'MotionComment.motion_comment_id';
b_use('ClassWrapper.TupleTag')->wrap_methods(
    __PACKAGE__, __PACKAGE__->TUPLE_TAG_INFO);

sub TUPLE_TAG_INFO {
    return {
	moniker => $_MC->TUPLE_TAG_PREFIX,
	primary_id_field => $_TAG_ID,
    };
}

sub execute_empty {
    my($self) = @_;
    $self->load_from_model_properties('Motion');
    return;
}

sub execute_ok {
    my($self) = @_;
    return unless $self->req('Model.MotionList')->can_comment;
    $self->internal_put_field('MotionComment.motion_comment_id' =>
        $self->new_other('MotionComment')
	    ->create($self->get_model_properties('MotionComment'))
		->get('motion_comment_id'));
    return;
}

sub get_tuple_use_moniker {
    my($self) = @_;
    return $self->req(qw(Model.MotionList TupleUse.moniker));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
	visible => [qw(
	    MotionComment.comment
	)],
	other => [
	    [qw(Motion.motion_id MotionComment.motion_id)],
	    'MotionComment.motion_comment_id',
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

1;
