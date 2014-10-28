# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::Permission;
use strict;
use Bivio::Base 'Type.EnumDelegator';

# C<Auth.Permission> is used to specify a task's access
# permissions.  See L<Agent.Task|Agent.Task> for
# how the permissions are used.
#
# See L<Agent.TaskId|Agent.TaskId> and
# L<Delegate.TaskId|Delegate.TaskId>
# for how you define permissions on tasks.
#
# See L<Agent.Task|Agent.Task> and
# L<Delegate.SimpleAuthSupport|Delegate.SimpleAuthSupport>
# for how permissions are checked.
#
# See L<Biz.Model::RealmRole|Biz.Model::RealmRole>
# and L<Agent.Request|Agent.Request> for how users
# are assigned roles in realms.  This table must be configured if
# you want to use permissions.
#
# You can avoid the use of permissions by delegating
# L<Auth.Support|Auth.Support> to
# L<Delegate.NoDbAuthSupport|Delegate.NoDbAuthSupport>.

__PACKAGE__->compile;

sub is_continuous {
    # Permissions aren't continuous, because they may go away or have
    # gaps across delegate aggregations.
    return 0;
}

1;
