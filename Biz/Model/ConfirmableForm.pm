# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ConfirmableForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_TI) = b_use('Agent.TaskId');

sub check_redirect_to_confirmation_form {
    my($self, $task) = @_;
    return if $self->unsafe_get('is_confirmed');
    $self->req->server_redirect($_TI->from_name($task));
    # DOES NOT RETURN
}

sub execute_unwind {
    my($self) = @_;

    if ($self->get('is_confirmed')) {
	my($res) = $self->validate_and_execute_ok;
	return if $self->in_error;
	return $res || $self->internal_redirect_next;
    }
    return shift->SUPER::execute_unwind(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	hidden => [
	    {
		name => 'is_confirmed',
		type => 'Boolean',
	        constraint => 'NONE',
	    },
	],
    });
}

1;
