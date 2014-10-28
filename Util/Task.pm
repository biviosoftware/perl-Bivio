# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Task;
use strict;
use Bivio::Base 'Bivio.ShellUtil';



sub USAGE {
    return <<'EOF';
usage: bivio Task [options] command [args..]
commands
  can_user_execute_task task [facade] -- asks if user can execute
EOF
}

sub can_user_execute_task {
    sub CAN_USER_EXECUTE_TASK {[[qw(task Agent.TaskId)], [qw(?facade Name)]]}
    my($self, $bp) = shift->parameters(\@_);
    $self->initialize_fully;
    b_use('UI.Facade')->setup_request($bp->{facade}, $self->req)
	if $bp->{facade};
    return $self->req->can_user_execute_task($bp->{task});
}

1;
