# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Auth::Permission;
use strict;
$Bivio::Auth::Permission::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Auth::Permission::VERSION;

=head1 NAME

Bivio::Auth::Permission - used to define task access requirements

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
how the permissions are defined.

NOTE: When you add a new permission, you must update the
      corresponding table (realm_role_t) in the database.
      Use b-realm-role for this.

Permissions which end in "_TRANSIENT" are not stored in the database.

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
	Bivio::IO::ClassLoader->delegate_require_info(__PACKAGE__));

=head1 METHODS

=cut

=for html <a name="is_continuous"></a>

=head2 static is_continuous() : false

Task Ids aren't continuous.  Tasks can go away.

=cut

sub is_continuous {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
