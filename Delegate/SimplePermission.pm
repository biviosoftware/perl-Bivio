# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimplePermission;
use strict;
$Bivio::Delegate::SimplePermission::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::SimplePermission::VERSION;

=head1 NAME

Bivio::Delegate::SimplePermission - default permissions for simplest site

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::SimplePermission;

=cut

use Bivio::Delegate;
@Bivio::Delegate::SimplePermission::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::Delegate::SimplePermission> returns default permissions for
simplest bOP site.

You can extend this delegate with:

    sub get_delegate_info {
	return [
	    @{Bivio::Delegate::SimplePermission->get_delegate_info()},
	    ...my permissions...
	];
    }

Start your permissions at 20.  Don't worry about dups, because
L<Bivio::Type::Enum|Bivio::Type::Enum> will die if you overlap.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 static get_delegate_info() : array_ref

Returns the permissions which are specified in
L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>,
checked by L<Bivio::Agent::Task|Bivio::Agent::Task>,
and configured for each realm/role in
L<Bivio::Biz::Model::RealmRole|Bivio::Biz::Model::RealmRole>.

=over 4

=item ANYBODY

This permission should be set for all roles.

=item ANY_USER

Set for all roles which are played by users logged into the site,
whether they are L<RealmUser|Bivio::Biz::Model::RealmUser> or not.

=item DATA_READ

The role can read, but not modify data in the realm.

=item DATA_WRITE

The role can write, but not read data in the realm.

=back

=cut

sub get_delegate_info {
    return [
	ANYBODY => [1],
	ANY_USER => [2],
	DATA_READ => [3],
	DATA_WRITE => [4],
    ];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
