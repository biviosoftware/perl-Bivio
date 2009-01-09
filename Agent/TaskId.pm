# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::TaskId;
use strict;
use Bivio::Base 'Type.EnumDelegator';

# C<Bivio::Agent::TaskId> defines all possible "tasks" within bOP site.  A
# structure of a task is defined in L<Bivio::Agent::TaskBivio::Agent::Task>.
#
# The syntax of the configuration table is defined as follows:
#
#     NAME_OF_TASK
#     <unique number for enumerated type>
#     <Bivio::Auth::RealmType>
#     <Bivio::Auth::PermissionSet>
#     <executable object1>
#     <executable object2>
#     ...
#     attribute1=value1
#     attribute2=value2
#     ...
#
# The first two entries are what defines the TaskId enumerated type.
# The subsequent entries are configuration for the Task instance itself.
# See L<Bivio::Agent::Task|Bivio::Agent::Task> for a description.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CFG) = b_use('IO.ClassLoader')->delegate_require_info(__PACKAGE__);
__PACKAGE__->compile([
    map(($_->[0], [$_->[1]]), @{__PACKAGE__->get_cfg_list})]);

sub get_cfg_list {
    return $_CFG;
}

sub is_continuous {
    return 0;
}

1;
