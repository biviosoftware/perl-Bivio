# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Auth::PermissionSet;
use strict;
$Bivio::Auth::PermissionSet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Auth::PermissionSet::VERSION;

=head1 NAME

Bivio::Auth::PermissionSet - permission set for tasks

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Auth::PermissionSet;

=cut

=head1 EXTENDS

L<Bivio::Type::EnumSet>

=cut

use Bivio::Type::EnumSet;
@Bivio::Auth::PermissionSet::ISA = ('Bivio::Type::EnumSet');

=head1 DESCRIPTION

C<Bivio::Auth::PermissionSet> is the storage format for the
task permissions.  Each element is a
L<Bivio::Auth::Permission|Bivio::Auth::Permission>.
A task may require more than one permission.
See L<Bivio::Agent::Task|Bivio::Agent::Task> and
L<Bivio::Auth::Realm|Bivio::Auth::Realm>
for more details.

=cut

#=IMPORTS
use Bivio::Auth::Permission;

#=VARIABLES
__PACKAGE__->initialize();

=head1 METHODS

=cut

=for html <a name="get_enum_type"></a>

=head2 get_enum_type() : Bivio::Type::Enum

Returns L<Bivio::Auth::Permission|Bivio::Auth::Permission>.

=cut

sub get_enum_type {
    return 'Bivio::Auth::Permission';
}

=for html <a name="get_width"></a>

=head2 get_width() : int

Returns 15.  That's 120 permissions.

=cut

sub get_width {
    return 15;
}

=for html <a name="includes"></a>

=head2 includes(Bivio::Auth::Permission perm_name) : boolean

Returns true if this permission set includes perm_name.

=cut

sub includes {
    my($proto, $perm_set, $perm_name) = @_;
    return $proto->is_set($perm_set, Bivio::Auth::Permission->$perm_name());
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
