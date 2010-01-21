# Copyright (c) 2001-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimpleAuthSupport;
use strict;
use Bivio::Base 'Collection.Attributes';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DEFAULT_PERMISSIONS) = {};
my($_RT) = b_use('Model.RowTag');
my($_RO) = b_use('Model.RealmOwner');
my($_RR) = b_use('Model.RealmRole');
my($_PS) = b_use('Auth.PermissionSet');
my($_P) = b_use('Auth.Permission');
my($_USER) = b_use('Auth.RealmType')->USER;
our($_TRACE);

sub get_auth_user {
    # (proto, Agent.Request) : Biz.Model
    # Expects I<Request.auth_user_id> to be set.  If it isn't set, returns
    # C<undef>.  LoginForm or some other cookie handler should set this.
    my(undef, $req) = @_;
    # This special field is set by one of the handlers (LoginForm).
    my($auth_user_id) = $req->unsafe_get('auth_user_id');
    _trace('auth_user_id=', $auth_user_id) if $_TRACE;
    return
	undef unless $auth_user_id;
    # Make sure user loads and has a valid password (could login)
    my($auth_user) = $_RO->new($req);
    return $auth_user
	if $auth_user->unauth_load({
	    realm_id => $auth_user_id,
	    realm_type => $_USER,
	}) && $auth_user->has_valid_password;
    return undef;
}

sub load_permissions {
    # (proto, Auth.Realm, Auth.Role, Agent.Request) : Auth.PermissionSet
    # Returns the permission set from RealmRole table.  If there are no permissions,
    # loads default permissions from RealmRole table.
    my($proto, $realm, $role, $req) = @_;
    my($owner) = $realm->unsafe_get('owner');
    if ($owner) {
	my($map) = $req->get_if_exists_else_put(
	    __PACKAGE__ . '.' . $realm->get('id'),
	    sub {_map_permissions($_RR->new($req), $realm->get('id'))},
	);
	return $map->{$role}
	    if defined($map->{$role});
    }
    my($rti) = $realm->get('type')->as_int;
    _load_default_permissions($rti, $req)
	unless $_DEFAULT_PERMISSIONS->{$rti};
    my($res) = $_DEFAULT_PERMISSIONS->{$rti}->{$role};
    b_die($realm, ': unable to load default permissions for ', $role)
	unless defined($res);
    return $res;
}

sub task_permission_ok {
    # (proto, Auth.PermissionSet, Auth.PermissionSet, Agent.Request) : boolean
    # Returns true if I<user> has all permissions in I<task>.
    # Computes SUPER_USER_TRANSIENT and SUBSTITUTE_USER_TRANSIENT.
    my($proto, $user, $task, $req) = @_;
    foreach my $op ('', qw(super_user substitute_user test)) {
	if ($op) {
	    my($method) = 'is_' . $op;
	    next
		unless $req->$method();
	    $_PS->set(
		\$user,
		$_P->from_name($op . '_transient'));
	    _trace($op, ' user: ', $user) if $_TRACE;
	}
	# Does this role have all the required permission?
	return 1 if ($user & $task) eq $task;
    }
    _trace('insufficient privileges') if $_TRACE;
    return 0;
}

sub unsafe_get_user_pref {
    my($proto, $pref, $req, $res) = @_;
    return 0
	unless my $u = $req->get('auth_user_id');
    return defined($$res = $_RT->new($req)->get_value($u, $pref)) ? 1 : 0;
}

sub _load_default_permissions {
    my($rti, $req) = @_;
    my($rr) = $_RR->new($req);
#TODO: Use RealmRole->get_permission_map
    $_DEFAULT_PERMISSIONS->{$rti} = {
	%{$rr->EMPTY_PERMISSION_MAP},
	%{_map_permissions($rr, $rti)},
    };
    return;
}

sub _map_permissions {
    my($rr, $realm_id) = @_;
    return {@{$rr->map_iterate(
	sub {
	    my($it) = @_;
	    return ($it->get('role') => $it->get('permission_set'));
	},
	'unauth_iterate_start',
	'role',
	{realm_id => $realm_id},
    )}};
}

1;
