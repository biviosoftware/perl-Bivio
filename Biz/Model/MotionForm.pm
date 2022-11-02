# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionForm;
use strict;
use Bivio::Base 'Model.FormModeBaseForm';

my($_MS) = b_use('Type.MotionStatus');
my($_MT) = b_use('Type.MotionType');

sub LIST_MODEL {
    return 'MotionList';
}

sub MOTIONS_FOLDER {
    return '/Polls/';
}

sub PROPERTY_MODEL {
    return 'Motion';
}

sub execute_empty_create {
    my($self) = @_;
    $self->internal_put_field('Motion.status' => $_MS->OPEN);
    $self->internal_put_field('Motion.type' => $_MT->VOTE_PER_USER);
    return;
}

sub execute_empty_edit {
    my($self) = @_;
    $self->load_from_model_properties('Motion');
    return;
}

sub execute_ok_create {
    my($self) = @_;
     $self->new_other('Motion')->create($self->get_model_properties('Motion'));
    _add_file($self);
     return shift->SUPER::execute_ok_create;
}

sub execute_ok_edit {
    my($self) = @_;
    $self->update_model_properties('Motion');
    _add_file($self);
    return;
}

sub execute_unwind {
    my($self) = @_;
    return;
}

sub get_motion_document {
    my($self) = @_;
    return $self->get('Motion.motion_file_id')
        ? $self->new_other('RealmFile')->load({
            realm_file_id => $self->get('Motion.motion_file_id'),
        })
        : undef;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
        visible => [qw(
            Motion.name
            Motion.question
            Motion.status
            Motion.type
        ),
            {
                name => 'file',
                type => 'FileField',
                constraint => 'NONE',
            },
        ],
        hidden => [qw(
            Motion.motion_file_id
        )],
        other => [qw(
            Motion.motion_id
            Motion.name_lc
        )],
    });
}

sub _add_file {
    my($self) = @_;
    return unless $self->get('file');
    my($name) = b_use('Model.FileChangeForm')
        ->validate_file_name($self, 'file');
    return if $self->in_error;
    $self->req('Model.Motion')->update({
        motion_file_id => $self->new_other('RealmFile')->create_or_update_with_content({
            override_is_read_only => 1,
            path => $self->MOTIONS_FOLDER . $name,
            is_read_only => 1,
        }, $self->get('file')->{content})->get('realm_file_id'),
    });
    return;
}

1;
