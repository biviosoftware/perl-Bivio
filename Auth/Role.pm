# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Auth::Role;
use strict;
$Bivio::Auth::Role::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Auth::Role - authorized roles enum

=head1 SYNOPSIS

    use Bivio::Auth::Role;
    Bivio::Auth::Role->ANON;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Auth::Role::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Auth::Role> defines the roles users play in a
L<Bivio::Auth::Realm|Bivio::Auth::Realm>.
A role is a collection of privileges.  A privilege is a the ability
to execute a particular L<Bivio::Agent::Task|Bivio::Agent::Task>
within a realm.  For example, an C<ADMIN> may be granted the
ability to execute
L<Bivio::Agent::TaskId::CLUB_ADD_MEMBER|Bivio::Agent::TaskId/"CLUB_ADD_MEMBER">
in the L<Bivio::Auth::Realm::CLUB|Bivio::Auth::Realm/"CLUB">.

The following roles are defined:

=over 4

=item UNKNOWN

unknown: user has yet to be authenticated

=item ANONYMOUS

not a user: user not supplied with request or unable to authenticate

=item USER

any user: privileges of any authenticated user, not particular to realm

=item GUEST

non-member: limited privileges

=item MEMBER

member: normal privileges

=item ACCOUNTANT

accountant: normal and financial transaction privileges

=item ADMINISTRATOR

administrator: all privileges

=back

=cut

#=IMPORTS

#=VARIABLES

__PACKAGE__->compile(
    'UNKNOWN' => [
    	0,
	'Unknown',
	'user has yet to be authenticated',
    ],
    'ANONYMOUS' => [
    	1,
	'Anonymous',
	'user not supplied with request or unable to authenticate',
    ],
    'USER' => [
    	2,
	'Any User',
	'privileges of any authenticated user, not particular to realm',
    ],
    'GUEST' => [
    	3,
	'Guest',
	'limited access to realm',
    ],
    'MEMBER' => [
    	4,
	'Member',
	'normal participant in realm',
    ],
    'ACCOUNTANT' => [
    	5,
	'Accountant',
	'normal and financial transaction privileges',
    ],
    'ADMINISTRATOR' => [
    	6,
	'Administrator',
	'all privileges',
    ],
);

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
