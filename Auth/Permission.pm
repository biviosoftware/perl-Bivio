# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Auth::Permission;
use strict;
$Bivio::Auth::Permission::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Auth::Permission::VERSION;

=head1 NAME

Bivio::Auth::Permission - used to define access requirements for tasks

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Auth::Permission;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Auth::Permission::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Auth::Permission> is used to specify a task's access
permissions.  See L<Bivio::Agent::Task|Bivio::Agent::Task> for
how the permissions are used.


See L<Bivio::Agent::TaskId|Bivio::Agent::TaskId> and
L<Bivio::Delegate::SimpleTaskId|Bivio::Delegate::SimpleTaskId>
for how you define permissions on tasks.

See L<Bivio::Agent::Task|Bivio::Agent::Task> and
L<Bivio::Delegate::SimpleAuthSupport|Bivio::Delegate::SimpleAuthSupport>
for how permissions on checked.

See L<Bivio::Biz::Model::RealmRole|Bivio::Biz::Model::RealmRole>
and L<Bivio::Agent::Request|Bivio::Agent::Request> for how users
are assigned roles in realms.  This table must be configured if
you want to use permissions.

You can avoid the use of permissions by delegating
L<Bivio::Auth::Support|Bivio::Auth::Support> to
L<Bivio::Delegate::NoDbAuthSupport|Bivio::Delegate::NoDbAuthSupport>.

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
	Bivio::IO::ClassLoader->delegate_require_info(__PACKAGE__));

=head1 METHODS

=cut

=for html <a name="is_continuous"></a>

=head2 static is_continuous() : false

Permissions aren't continuous, because they may go away or have
gaps across delegate aggregations.

=cut

sub is_continuous {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
