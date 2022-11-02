# Copyright (c) 2005-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Model::WorkflowStepForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub execute_ok {
    # Stuffs current task in context.
    my($self) = @_;
    $self->put_context_fields(
        prev_task => $self->req('task_id')->get_long_desc,
    ) if $self->has_context_field('prev_task');
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
    });
}

1;
