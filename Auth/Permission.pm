# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::Permission;
use strict;
use Bivio::Base 'Type.EnumDelegator';

# C<Bivio::Auth::Permission> is used to specify a task's access
# permissions.  See L<Bivio::Agent::Task|Bivio::Agent::Task> for
# how the permissions are used.
#
# See L<Bivio::Agent::TaskId|Bivio::Agent::TaskId> and
# L<Bivio::Delegate::TaskId|Bivio::Delegate::TaskId>
# for how you define permissions on tasks.
#
# See L<Bivio::Agent::Task|Bivio::Agent::Task> and
# L<Bivio::Delegate::SimpleAuthSupport|Bivio::Delegate::SimpleAuthSupport>
# for how permissions are checked.
#
# See L<Bivio::Biz::Model::RealmRole|Bivio::Biz::Model::RealmRole>
# and L<Bivio::Agent::Request|Bivio::Agent::Request> for how users
# are assigned roles in realms.  This table must be configured if
# you want to use permissions.
#
# You can avoid the use of permissions by delegating
# L<Bivio::Auth::Support|Bivio::Auth::Support> to
# L<Bivio::Delegate::NoDbAuthSupport|Bivio::Delegate::NoDbAuthSupport>.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile;

sub is_continuous {
    # Permissions aren't continuous, because they may go away or have
    # gaps across delegate aggregations.
    return 0;
}

1;
