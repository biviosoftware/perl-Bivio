# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::Role;
use strict;
$Bivio::Delegate::Role::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::Role::VERSION;

=head1 NAME

Bivio::Delegate::Role - Roles

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::Role;

=cut

=head1 EXTENDS

L<Bivio::Delegate>

=cut

use Bivio::Delegate;
@Bivio::Delegate::Role::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::Delegate::Role> implements the common Roles in bOP,
defined as follows:

The following roles are defined:

=over 4

=item UNKNOWN

unknown: user has yet to be authenticated

=item ANONYMOUS

not a user: user not supplied with request or unable to authenticate

=item USER

any user: privileges of any authenticated user, not particular to realm

=item WITHDRAWN

withdrawn member: very limited access to this realm

=item GUEST

non-member: limited privileges

=item MEMBER

member: normal privileges

=item ACCOUNTANT

accountant: normal and financial transaction privileges

=item ADMINISTRATOR

administrator: all privileges

=back

You should extend this class if you have new Roles in your application.
The numbers 0-19 are reserved by this module so your first Role would
look like:

    sub get_delegate_info {
	my($proto) = @_;
	return [
            @{$proto->SUPER::get_delegate_info},
	    MY_NEW_ROLE => [
	        20,
		undef,
		'some new role',
	    ],
        ];
    }

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 get_delegate_info() : array_ref

Returns standard realm types.

=cut

sub get_delegate_info {
    return [
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
        'WITHDRAWN' => [
            3,
            'Withdrawn Member',
            'very limited access to this realm',
        ],
        'GUEST' => [
            4,
            'Guest',
            'limited access to realm',
        ],
        'MEMBER' => [
            5,
            'Member',
            'normal participant in realm',
        ],
        'ACCOUNTANT' => [
            6,
            'Accountant',
            'normal and financial transaction privileges',
        ],
        'ADMINISTRATOR' => [
            7,
            'Administrator',
            'all privileges',
        ],
    ];
}

=for html <a name="is_admin"></a>

=head2 is_admin() : boolean

Returns true if the role is an administrator.

=cut

sub is_admin {
    my($self) = @_;
    return $self->equals_by_name('ADMINISTRATOR');
}

=for html <a name="is_member"></a>

=head2 is_member() : boolean

Returns true if the role is a member.

=cut

sub is_member {
    my($self) = @_;
    return $self->is_admin
        || $self->equals_by_name(qw(MEMBER ACCOUNTANT)) ? 1 : 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
