# Copyright (c) 2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::DefaultTaskId;
use strict;
use Bivio::Base 'Delegate.TaskId';


sub get_delegate_info {
    my($proto) = @_;
    return $proto->merge_task_info(@{$proto->standard_components}, []);
}

1;
