# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimpleAuthSupport;
use strict;
$Bivio::Delegate::SimpleAuthSupport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::SimpleAuthSupport::VERSION;

=head1 NAME

Bivio::Delegate::SimpleAuthSupport - basic authentication support

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::SimpleAuthSupport;

=cut

=head1 EXTENDS

L<Bivio::Delegate>

=cut

use Bivio::Delegate;
@Bivio::Delegate::SimpleAuthSupport::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::Delegate::SimpleAuthSupport> provides basic authentication
support.  Uses database to retrieve permissions.

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my(%_DEFAULT_PERMISSIONS);

=head1 METHODS

=cut

=for html <a name="get_auth_user"></a>

=head2 static get_auth_user(Bivio::Agent::Request req) : Bivio::Biz::Model

Expects I<Request.auth_user_id> to be set.  If it isn't set, returns
C<undef>.  LoginForm or some other cookie handler should set this.

=cut

sub get_auth_user {
    my(undef, $req) = @_;

    # This special field is set by one of the handlers (LoginForm).
    my($auth_user_id) = $req->unsafe_get('auth_user_id');
    _trace('auth_user_id=', $auth_user_id) if $_TRACE;
    return undef unless $auth_user_id;

    # Make sure user loads and has a valid password (could login)
    my($auth_user) = Bivio::Biz::Model->new($req, 'RealmOwner');
    return $auth_user
	    if $auth_user->unauth_load(realm_id => $auth_user_id,
		    realm_type => Bivio::Auth::RealmType->USER)
	    && $auth_user->has_valid_password;
    return undef;
}

=for html <a name="load_permissions"></a>

=head2 static load_permissions(Bivio::Auth::Realm realm, Bivio::Auth::Role role, Bivio::Agent::Request req) : Bivio::Auth::PermissionSet

Returns the permission set from RealmRole table.  If there are no permissions,
loads default permissions from RealmRole table.

=cut

sub load_permissions {
    my(undef, $realm, $role, $req) = @_;
    my($owner) = $realm->unsafe_get('owner');
    if ($owner) {
	my($rr) = Bivio::Biz::Model->new($req, 'RealmRole');
	# Try to load for just this role explicitly and cache.
	return $rr->get('permission_set')
		if $rr->unauth_load(
			realm_id => $realm->get('id'), role => $role);
    }

    my($rti) = $realm->get('type')->as_int;
    _load_default_permissions($rti, $req) unless $_DEFAULT_PERMISSIONS{$rti};

    # Copy just this role's permission if there is an owner
    my($res) = $_DEFAULT_PERMISSIONS{$rti}->{$role};
    # Return the permission, but make sure it exists
    Bivio::Die->die($realm, ': unable to load default permissions for ', $role)
		unless defined($res);
    return $res;
}

=for html <a name="task_permission_ok"></a>

=head2 static task_permission_ok(Bivio::Auth::PermissionSet user, Bivio::Auth::PermissionSet task, Bivio::Agent::Request req) : boolean

Returns true if I<user> has all permissions in I<task>.

=cut

sub task_permission_ok {
    my(undef, $user, $task, $req) = @_;
    return ($user & $task) eq $task ? 1 : 0;
}

=for html <a name="unsafe_get_user_pref"></a>

=head2 static unsafe_get_user_pref() : boolean

Preferences not suppported.  Always returns false.

=cut

sub unsafe_get_user_pref {
    return 0;
}

#=PRIVATE METHODS

# _load_default_permissions(int rti, Bivio::Agent::Request rti)
#
# Loads default permissions for this rti (RealmType->as_int)
# The RealmRole table maps the RealmType->as_int to the realm_id
# for defaults.
#
sub _load_default_permissions {
    my($rti, $req) = @_;
    # Copy the default (if loaded) and return
    my($rr) = Bivio::Biz::Model->new($req, 'RealmRole');
    # Load and save the defaults
    my($dp) = $_DEFAULT_PERMISSIONS{$rti} = {};
    my($it) = $rr->unauth_iterate_start('role', {realm_id => $rti});
    my(%row);
    while ($rr->iterate_next($it, \%row)) {
	$dp->{$row{role}} = $row{permission_set};
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
