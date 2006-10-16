# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::TaskId;
use strict;
$Bivio::Agent::TaskId::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Agent::TaskId::VERSION;

=head1 NAME

Bivio::Agent::TaskId - enum of identifying all tasks in a bOP site

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Agent::TaskId;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Agent::TaskId::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Agent::TaskId> defines all possible "tasks" within bOP site.  A
structure of a task is defined in L<Bivio::Agent::TaskBivio::Agent::Task>.

The syntax of the configuration table is defined as follows:

    NAME_OF_TASK
    <unique number for enumerated type>
    <Bivio::Auth::RealmType>
    <Bivio::Auth::PermissionSet>
    <executable object1>
    <executable object2>
    ...
    attribute1=value1
    attribute2=value2
    ...

The first two entries are what defines the TaskId enumerated type.
The subsequent entries are configuration for the Task instance itself.
See L<Bivio::Agent::Task|Bivio::Agent::Task> for a description.

=cut

#=IMPORTS
use Bivio::IO::ClassLoader;

#=VARIABLES
my($_CFG) = Bivio::IO::ClassLoader->delegate_require_info(__PACKAGE__);

__PACKAGE__->compile([
    map {($_->[0], [$_->[1]])} @$_CFG
]);

=head1 METHODS

=cut

=for html <a name="get_cfg_list"></a>

=head2 static get_cfg_list() : array_ref

ONLY TO BE CALLED BY L<Bivio::Agent::Tasks>.

=cut

sub get_cfg_list {
    return $_CFG;
}

=for html <a name="is_continuous"></a>

=head2 static is_continuous() : false

Task Ids aren't continuous.  Tasks can go away.

=cut

sub is_continuous {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
