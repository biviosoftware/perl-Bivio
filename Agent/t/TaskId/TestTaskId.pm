# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Agent::t::TaskId::TestTaskId;
use strict;
use Bivio::Base 'Delegate.TaskId';


sub get_delegate_info {
    my($proto) = @_;
    return $proto->merge_task_info(
	'blog',
	[
	    [qw(
	        TEST_TASK_ID_1
		500
		ANY_OWNER
		ANYBODY
		Action.EmptyReply
	    )],
	],
    );
}

1;
