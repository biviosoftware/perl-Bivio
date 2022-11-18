# Copyright (c) 2010 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ContextWritebackForm;
use strict;
use Bivio::Base 'Biz.FormModel';

                                       
sub TARGET_FIELD {
    return 'target_field';
}

sub execute_cancel {
    my($self) = @_;
    return $self->internal_redirect_next;
}

sub execute_empty {
    my($self) = @_;
    return 'no_context_task'
        unless _validate_context($self);
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->internal_stay_on_page;
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
    });
}

sub get_target_value {
    my($self) = @_;
    return ($self->unsafe_get_context_field(_target_field($self)))[0];
}

sub set_target_and_redirect {
    my($self, $value) = @_;
    return 'no_context_task'
        unless _validate_context($self);
    $self->put_context_fields(_target_field($self) => $value);
    return $self->internal_redirect_next;
}

sub target_config {
    my($proto) = @_;
    return {
        name => $proto->TARGET_FIELD,
        type => 'Name',
        constraint => 'NONE',
    };
}

sub _target_field {
    my($self) = @_;
    return ($self->unsafe_get_context_field($self->TARGET_FIELD))[0];
}

sub _validate_context {
    my($self) = @_;
    return 1 unless $self->req(qw(task require_context));
    return 1 if $self->unsafe_get_context
        && $self->unsafe_get_context->get('form_model')
        && _target_field($self);
    b_warn('context form w/invalid context');
    return 0;
}

1;
