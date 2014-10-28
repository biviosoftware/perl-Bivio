# Copyright (c) 2005-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Model::WorkflowCallerForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub execute_empty {
    # Calls WORKFLOW_STEP_1
    return {
	method => 'server_redirect',
	task_id => 'WORKFLOW_STEP_1',
	require_context => 1,
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	visible => [
	    {
		name => 'prev_task',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

1;
