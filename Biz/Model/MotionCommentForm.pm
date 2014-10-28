# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionCommentForm;
use strict;
use Bivio::Base 'Model.FormModeBaseForm';

my($_MC) = b_use('Model.MotionComment');
my($_TAG_ID) = 'MotionComment.motion_comment_id';
b_use('ClassWrapper.TupleTag')->wrap_methods(
    __PACKAGE__, __PACKAGE__->TUPLE_TAG_INFO);

sub LIST_MODEL {
    return 'MotionCommentList';
}

sub PROPERTY_MODEL {
    return 'MotionComment';
}

sub TUPLE_TAG_INFO {
    return {
	moniker => $_MC->TUPLE_TAG_PREFIX,
	primary_id_field => $_TAG_ID,
    };
}

sub execute_empty_create {
    return;
}

sub execute_empty_edit {
    my($self) = @_;
    $self->load_from_model_properties('MotionComment');
    return;
}

sub execute_ok_create {
    my($self) = @_;
    return unless $self->req('Model.MotionList')->can_comment;
    $self->internal_put_field('MotionComment.motion_comment_id' =>
        $self->new_other('MotionComment')
	    ->create($self->get_model_properties('MotionComment'))
		->get('motion_comment_id'));
    return;
}

sub execute_ok_edit {
    my($self) = @_;
    $self->req('Model.MotionComment')->update(
	$self->get_model_properties('MotionComment'));
    return;
}

sub get_tuple_use_moniker {
    my($self) = @_;
    return $self->req(qw(Model.MotionList TupleUse.moniker));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
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
    $self->load_from_model_properties($self->get_model('Motion'));
    return shift->SUPER::internal_pre_execute(@_);
}

1;
