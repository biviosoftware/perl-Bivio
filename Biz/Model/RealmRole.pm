# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmRole;
use strict;
$Bivio::Biz::Model::RealmRole::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::RealmRole::VERSION;

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
use Bivio::Auth::PermissionSet;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="add_permissions"></a>

=head2 add_permissions(Bivio::Biz::Model::RealmOwner realm, array_ref roles, Bivio::Auth::PermissionSet permissions)

Adds I<permissions> to I<roles> for I<realm>.

Always calls L<initialize_permissions|"initialize_permissions"> first.

=cut

sub add_permissions {
    my($self, $realm, $roles, $permissions) = @_;
    $self->initialize_permissions($realm);

    my($realm_id) = $realm->get('realm_id');
    foreach my $role (@$roles) {
	$self->unauth_load_or_die(realm_id => $realm_id, role => $role);
        $self->update({
	    permission_set => $self->get('permission_set') | $permissions});
    }
    return;
}

=for html <a name="change_public_permissions"></a>

=head2 change_public_permissions(Bivio::Biz::Model::RealmOwner realm, string method)

Changes public permissions on a club using L<add_permissions|"add_permissions">
or L<remove_permissions|"remove_permissions"> for a club.

=cut

sub change_public_permissions {
    my($self, $realm, $method) = @_;
    my($req) = $realm->get_request;

    # Mail/file read and post is available for all users and visitors.
    my($ps) = Bivio::Auth::PermissionSet->get_min;
    Bivio::Auth::PermissionSet->set(\$ps,
            Bivio::Auth::Permission::DOCUMENT_READ(),
            Bivio::Auth::Permission::MAIL_POST(),
            Bivio::Auth::Permission::MAIL_READ(),
           );
    my($roles) = [
        Bivio::Auth::Role::USER(),
        Bivio::Auth::Role::WITHDRAWN(),
        Bivio::Auth::Role::ANONYMOUS(),
    ];
    Bivio::Biz::Model::RealmRole->new($req)->$method($realm, $roles, $ps);

    # Mail forward is only available for users and withdrawn
    pop(@$roles);
    $ps = Bivio::Auth::PermissionSet->get_min;
    Bivio::Auth::PermissionSet->set(\$ps,
            Bivio::Auth::Permission::MAIL_FORWARD(),
           );
    Bivio::Biz::Model::RealmRole->new($req)->$method($realm, $roles, $ps);
    return;
}

=for html <a name="get_roles_for_permission"></a>

=head2 get_roles_for_permission(Bivio::Biz::Model::RealmOwner realm, Bivio::Auth::Permission permission) : Bivio::Auth::RoleSet

Return all roles for I<realm> which have I<permission> set.

=cut

sub get_roles_for_permission {
    my($self, $realm, $permission) = @_;
    my($type_id) = $realm->get('realm_type')->as_int;
    my($realm_id) = $realm->get('realm_id');
    my($roles) = '';
    foreach my $role (Bivio::Auth::Role::get_list()) {
        next if $role eq Bivio::Auth::Role::UNKNOWN();
	$self->unauth_load(realm_id => $realm_id, role => $role)
                || $self->unauth_load_or_die(realm_id => $type_id, role => $role);
        my($p) = $self->get('permission_set');
        Bivio::Auth::RoleSet->set(\$roles, $role)
                if Bivio::Auth::RoleSet->is_set(\$p, $permission);
    }
    return $roles;
}

=for html <a name="initialize_permissions"></a>

=head2 initialize_permissions(Bivio::Biz::Model::RealmOwner realm)

Initializes the permissions for I<realm> if not already set.  Uses the defaults
for I<realm>'s type.

=cut

sub initialize_permissions {
    my($self, $realm) = @_;
    my($type_id) = $realm->get('realm_type')->as_int;
    my($realm_id) = $realm->get('realm_id');
    foreach my $role (Bivio::Auth::Role::get_list()) {
        next if $role eq Bivio::Auth::Role::UNKNOWN();
        # Skip role if already cloned
        next if $self->unauth_load(realm_id => $realm_id, role => $role);

        $self->create({realm_id => $realm_id, role => $role,
            permission_set => $self->unauth_load_or_die(
		    realm_id => $type_id, role => $role)
	            ->get('permission_set')});
    }
    return;
}

=for html <a name="remove_permissions"></a>

=head2 remove_permissions(Bivio::Biz::Model::RealmOwner realm, array_ref roles, Bivio::Auth::PermissionSet permissions)

Removes I<permissions> from I<roles> for I<realm>.

Always calls L<initialize_permissions|"initialize_permissions"> first.

=cut

sub remove_permissions {
    my($self, $realm, $roles, $permissions) = @_;
    $self->initialize_permissions($realm);

    my($realm_id) = $realm->get('realm_id');
    foreach my $role (@$roles) {
	$self->unauth_load_or_die(realm_id => $realm_id, role => $role);
        $self->update({permission_set =>
	    $self->get('permission_set') & ~$permissions});
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
            realm_id => ['PrimaryId', 'PRIMARY_KEY'],
            role => ['Bivio::Auth::Role', 'PRIMARY_KEY'],
            permission_set => ['Bivio::Auth::PermissionSet',  'NOT_NULL'],
        },
	auth_id => 'realm_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
