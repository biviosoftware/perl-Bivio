# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmRole;
use strict;
$Bivio::Biz::Model::RealmRole::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::RealmRole - manipulate realm_role_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmRole;
    Bivio::Biz::Model::RealmRole->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmRole::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmRole> is the create, read, update,
and delete interface to the C<realm_role_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::PrimaryId;
use Bivio::Auth::PermissionSet;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="add_permissions"></a>

=head2 add_permissions(string realm_id, array_ref roles, Bivio::Auth::PermissionSet permissions)

Add permissions to the roles for the given realm.
Note: Creates entries for ALL ROLES if this one does not exist.

=cut

sub add_permissions {
    my($self, $realm_id, $roles, $permissions) = @_;

    # Copy permission set from CLUB if first role not found
    $self->_clone_realm(Bivio::Auth::RealmType->CLUB()->as_int, $realm_id)
            unless $self->unauth_load(realm_id => $realm_id,
                    role => $roles->[0]);

    my($ps, $role);
    foreach $role (@$roles) {
        # Load current permission set and add new ones
        $self->die('NOT_FOUND',
                { message => 'failed to load permission set', entity => $role})
                unless $self->unauth_load(realm_id => $realm_id, role => $role);
        $ps = $self->get('permission_set');
        $ps |= $permissions;
        $self->update({permission_set => $ps});
    }
    return;
}

=for html <a name="remove_permissions"></a>

=head2 remove_permissions(string realm_id, array_ref roles, Bivio::Auth::PermissionSet permissions)

Removes permissions from the roles for the given realm.

=cut

sub remove_permissions {
    my($self, $realm_id, $roles, $permissions) = @_;
    my($ps, $role);
    foreach $role (@$roles) {
        $self->die('NOT_FOUND', { message => 'missing role entry',
            role => $role, entity => $realm_id})
                unless $self->unauth_load(realm_id => $realm_id, role => $role);
        $ps = $self->get('permission_set') & ~$permissions;
        $self->update({permission_set => $ps});
    }
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_role_t',
	columns => {
            realm_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            role => ['Bivio::Auth::Role',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            permission_set => ['Bivio::Auth::PermissionSet',
    		Bivio::SQL::Constraint::NOT_NULL()],
        },
	auth_id => 'realm_id',
    };
}

#=PRIVATE METHODS

# _create(string existing_realm, string new_realm) : 
#
# Clone the permission set for all roles
#
sub _clone_realm {
    my($self, $existing, $new) = @_;

    my($ps);
    foreach my $role (Bivio::Auth::Role::get_list()) {
        next if $role eq Bivio::Auth::Role::UNKNOWN();
        $self->unauth_load(realm_id => $existing, role => $role);
        $ps = $self->get('permission_set');
        $self->create({realm_id => $new, role => $role,
            permission_set => $ps});
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
