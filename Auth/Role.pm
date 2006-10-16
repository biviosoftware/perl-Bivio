# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::Role;
use strict;
$Bivio::Auth::Role::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Auth::Role::VERSION;

=head1 NAME

Bivio::Auth::Role - authorized roles enum

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Auth::Role;
    Bivio::Auth::Role->ANONYMOUS();

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::EnumDelegator;
@Bivio::Auth::Role::ISA = ('Bivio::Type::EnumDelegator');

=head1 DESCRIPTION

C<Bivio::Auth::Role> defines the roles users play in a
L<Bivio::Auth::Realm|Bivio::Auth::Realm>.
A role is a collection of privileges.  A privilege is a the ability
to execute a particular L<Bivio::Agent::Task|Bivio::Agent::Task>
within a realm.  For example, an C<ADMINISTRATOR> may be granted the
ability to execute
L<Bivio::Agent::TaskId::CLUB_ADMIN_ADD_MEMBER|Bivio::Agent::TaskId/"CLUB_ADMIN_ADD_MEMBER">
in the L<Bivio::Auth::Realm::CLUB|Bivio::Auth::Realm/"CLUB">.

=cut

#=IMPORTS

#=VARIABLES

__PACKAGE__->compile();

=for html <a name="is_continuous"></a>

=head2 static is_continuous() : false

Roles are not continuous.

=cut

sub is_continuous {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
