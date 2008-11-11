# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmRole;
use strict;
use Bivio::Base 'Biz.PropertyModel';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PS) = b_use('Auth.PermissionSet');
my($_R) = b_use('Auth.Role');
my($_RS) = b_use('Auth.RoleSet');

sub add_permissions {
    return _do('add', @_);
}

sub get_permission_map {
    my($self, $realm) = @_;
    $realm = Bivio::Auth::Realm->new($realm, $self->get_request)
	unless $self->is_blessed($realm, 'Bivio::Auth::Realm');
    return {
	$realm->is_default ? ()
	      : %{$self->get_permission_map($realm->get_default_name)},
	@{$self->new->map_iterate(
	    sub {shift->get(qw(role permission_set))},
	    'unauth_iterate_start',
	    'role',
	    {realm_id => $realm->get('id')},
	)}
    };
}

sub get_roles_for_permission {
    my($self, $realm, $permission) = @_;
    my($map) = $self->get_permission_map($realm);
    my($roles) = $_RS->get_min;
    foreach my $role ($_R->get_non_zero_list) {
	$_RS->set(\$roles, $role)
            if $_PS->is_set($map->{$role}, $permission);
    }
    return $roles;
}

sub initialize_permissions {
    my($self, $realm) = @_;
    my($type_id) = $realm->get('realm_type')->as_int;
    my($realm_id) = $realm->get('realm_id');
    foreach my $role ($_R->get_non_zero_list) {
        # Skip role if already cloned
        next if $self->unauth_load(realm_id => $realm_id, role => $role);

	$self->unauth_load(realm_id => $type_id, role => $role);
	next if !$self->is_loaded();

        $self->create({realm_id => $realm_id, role => $role,
            permission_set => $self->get('permission_set')});
    }
    return;
}

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_role_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            role => [$_R, 'PRIMARY_KEY'],
            permission_set => [$_PS,  'NOT_NULL'],
        },
	auth_id => 'realm_id',
    };
}

sub remove_permissions {
    return _do('remove', @_);
}

sub _do {
    my($which, $self, $realm, $roles, $permissions) = @_;
    $self->initialize_permissions($realm);
    my($realm_id) = $realm->get('realm_id');
    foreach my $role (map($_R->from_any($_), @$roles)) {
	next unless $self->unauth_load(realm_id => $realm_id, role => $role);
	$self->update({
	    permission_set => $which eq 'add'
	            ? ($self->get('permission_set')
		        | _permissions($realm, $role, $permissions))
	            : ($self->get('permission_set')
		        & ~_permissions($realm, $role, $permissions)),
	});
	_trace(
	    'permissions: ',
	    $_PS->to_array($self->get('permission_set'))
	) if $_TRACE;
    }
    return;
}

sub _get_permission_set {
    my($realm, $role) = @_;
    my($rr) = $realm->new_other('RealmRole');
    return $rr->get('permission_set')
	    if $rr->unauth_load(
	        realm_id => $realm->get('realm_id'),
		role => $role,
	    );
    Bivio::Die->die($role->as_string, ": not set for realm");
    # DOES NOT RETURN
}

sub _permissions {
    my($realm, $role, $permissions) = @_;
    return $permissions
	unless ref($permissions);
    return $permissions
	if UNIVERSAL::isa($permissions, 'Bivio::Auth:::PermissionSet');

    my($ps) = $_PS->get_empty();
    foreach my $operand (@$permissions) {
	my($permission) = Bivio::Auth::Permission->unsafe_from_any($operand);
	if ($permission && $permission->get_name eq $operand) {
	    $_PS->set($ps, $permission);
	}
	else {
	    my($r) = $_R->unsafe_from_any($operand);
	    Bivio::Die->die($operand, ': neither a Role nor Permission')
		unless $r && $r->get_name eq $operand;
	    $$ps &= _get_permission_set($realm, $r);
	}
    }
    return $$ps;
}

1;
