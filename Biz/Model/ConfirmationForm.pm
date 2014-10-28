# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ConfirmationForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_TIA) = b_use('Type.TaskIdArray');

sub execute_cancel {
    my($self) = @_;
    return $self->internal_redirect_next;
}

sub execute_empty {
    my($self) = @_;
    if (_is_no_confirm_task($self)) {
	_save_context($self);
	return $self->validate_and_execute_ok;
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    _save_context($self);
    if ($self->unsafe_get('do_not_show_again')
	&& ! _is_no_confirm_task($self)) {
	$self->new_other('RowTag')->row_tag_replace_for_auth_user(
	    NO_CONFIRM_TASKS => $_TIA->new([
		@{_get_no_confirm_tasks($self)->as_array},
		$self->req('task_id')->as_int,
	    ]));
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
        require_context => 1,
	visible => [
	    {
		name => 'do_not_show_again',
		type => 'Boolean',
	        constraint => 'NONE',
	    },
	],
    });
}

sub _get_no_confirm_tasks {
    my($self) = @_;
    return $self->new_other('RowTag')
	->row_tag_get_for_auth_user('NO_CONFIRM_TASKS')
	|| $_TIA->new([]);
}

sub _is_no_confirm_task {
    my($self) = @_;
    return _get_no_confirm_tasks($self)
	->contains($self->req('task_id')->as_int);
}

sub _save_context {
    my($self) = @_;
    if ($self->has_context_field('is_confirmed')) {
	$self->put_context_fields(is_confirmed => 1);
    }
    return;
}

1;
