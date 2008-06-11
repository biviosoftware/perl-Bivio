# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::Realm;
use strict;
use Bivio::Auth::Permission;
use Bivio::Auth::PermissionSet;
use Bivio::Auth::Role;
use Bivio::Auth::Support;
use Bivio::Base 'Bivio::Collection::Attributes';
use Bivio::Die;
use Bivio::HTML;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;

# C<Bivio::Auth::Realm> defines the authorization policy for
# L<Bivio::Auth::Role|Bivio::Auth::Role> and
# L<Bivio::Agent::Task|Bivio::Agent::Task>.
# A task is authorized by
# L<can_user_execute_task|"can_user_execute_task">.
#
# Subclasses define the actual authorization policies.
#
#
#
# id : string
#
# Primary id of the owner or the RealmType as an int.
#
# owner : Bivio::Biz::Model::RealmOwner
#
# The particular instance of this realm.  Only used in the case of
# clubs and users.  General does not have an owner.
#
# owner_name : string
#
# Named retrieved from realm owner.  Not defined for the general realm.
# Always use this value instead of owner-E<gt>get('name').
#
# type : Bivio::Auth::RealmType
#
# Type of this realm.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_INITIALIZED) = 0;
my($_GENERAL);
my($_PI) = Bivio::Type->get_instance('PrimaryId');
my(@_USED_ROLES) = Bivio::Auth::Role->get_non_zero_list;
my($_RT) = __PACKAGE__->use('Auth.RealmType');

sub as_string {
    my($self) = @_;
    # Pretty prints the realm.
    my($owner) = $self->unsafe_get('owner');
    return ref($self)
	. '['
        . join(
	    ',',
	    $self->get('type')->get_name,
	    $owner ? $self->unsafe_get('owner_name', 'id') : (),
        ) . ']';
}

sub can_user_execute_task {
    my($self, $task, $req) = @_;
    # Returns true if I<auth_user> of I<req> can execute I<task>.

    # Is the task defined in the right realm?
    unless ($task->has_realm_type($self->get('type'))) {
	_trace($task->get('id'), ': no such task in ', $self->get('type'))
	    if $_TRACE;
	return 0;
    }
    return $self->does_user_have_permissions($task->get('permission_set'), $req);
}

sub do_default {
    my($proto, $op, $req) = @_;
    # Iterates all default realms, setting realms to default user.
    my($realm, $user) = $req->get(qw(auth_realm auth_user));
    $req->set_user('user');
    my($die) = Bivio::Die->catch(sub {
	foreach my $r ($_RT->get_non_zero_list) {
	    $req->set_realm($r->get_name);
	    last unless $op->($req->get('auth_realm'));
	}
	return;
    });
    $req->set_realm($realm);
    $req->set_user($user);
    $die->throw
	if $die;
    return;
}

sub does_user_have_permissions {
    my($self, $perms, $req) =  @_;
    # Does req.auth_user have I<perms> in this realm.
    $perms = ${Bivio::Auth::PermissionSet->from_array($perms)}
	if ref($perms) eq 'ARRAY';
    my($fields) = $self->[$_IDI];
    return Bivio::Auth::Support->task_permission_ok(
	_perm_set_from_all([map({
	    my($auth_role) = $_;
	    unless (defined($fields->{$auth_role})) {
		$fields->{$auth_role} = Bivio::Auth::Support->load_permissions(
		    $self, $auth_role, $req);
	    }
	    $fields->{$auth_role};
	} @{$req->get_auth_roles($self)})]),
	$perms,
	$req,
    );
}

sub equals {
    my($self, $that) = @_;
    # Returns true if I<self> is identical I<that>.
    return ref($self) eq ref($that) && $self->get('id') eq $that->get('id')
	? 1 : 0;
}

sub format_email {
    my($self) = @_;
    # How to mail to this realm.
    # This is more than caching. It allows for overriding.
    my($email) = $self->unsafe_get('_email');
    return $email if $email;

    # Compute and cache (since we are checking anyway)
    $email = $self->get('owner')->get_request->format_email(
	    $self->get('owner_name'));
    $self->put(_email => $email);
    return $email;
}

sub format_file {
    my($self) = @_;
    # Returns the root of the file server.
    # This is more than caching. It allows to override this value.
    my($file) = $self->unsafe_get('_file');
    return $file if $file;

    # Compute and cache (since we are checking anyway)
    $file = $self->get('owner_name');
    $self->put(_file => $file);
    return $file;
}

sub format_uri {
    my($self) = @_;
    # Returns the "home" of this realm, i.e. just its name.
    # Only works for realms with owners.
    # This is more than caching. It allows to override this value.
    my($uri) = $self->unsafe_get('_uri');
    return $uri if $uri;

    # Compute and cache (since we are checking anyway)
    $uri = $self->get('owner')->format_uri();
    $self->put(_uri => $uri);
    return $uri;
}

sub get_default_id {
    my($self) = @_;
    # Returns the default id for this realm.
    return $self->get('type')->as_int;
}

sub get_default_name {
    my($self) = @_;
    # Returns the owner name used for the three default realms (general, club, user).
    return lc($self->get('type')->get_name);
}

sub get_general {
    # Returns the singleton instance of the GENERAL realm.
    return $_GENERAL ||= _new(shift(@_));
}

sub get_type {
    my($proto) = @_;
    # Returns the RealmType for this realm.
    #
    # B<DEPRECATED>.
    # Get the type from the instance itself otherwise
    # just from class.
    return $proto->get('type') if ref($proto);
    Bivio::Die->die($proto, ': unknown realm class');
}

sub has_owner {
    # Returns true if has I<owner> (same as not is_default).
    return shift->is_default ? 0 : 1;
}

sub id_from_any {
    my($proto) = shift;
    # Returns the realm_id from I<realm_or_id>.  Can be a realm_id,
    # model with realm_id, instance, or self.
    my($realm_or_id) = @_ ? @_ : $proto;
    return ref($realm_or_id)
	? UNIVERSAL::isa($realm_or_id, 'Bivio::Auth::Realm')
        ? $realm_or_id->get('id')
	: UNIVERSAL::isa($realm_or_id, 'Bivio::Biz::Model')
	? $realm_or_id->get('realm_id')
        : Bivio::Die->die($realm_or_id, ': unhandled reference type')
	: $_PI->is_specified($realm_or_id) || $proto->is_default_id($realm_or_id)
	? $realm_or_id
	: Bivio::Die->die($realm_or_id, ': not a PrimaryId');
}

sub is_default {
    my($self) = @_;
    # Returns true if the realm is one of the default realms (general, user, club).
    return 1 if $self->get('type') == $_RT->GENERAL;
    return $self->get('owner')->is_default;
}

sub is_default_id {
    my(undef, $id) = @_;
    return $_RT->is_default_id($id);
}

sub is_general {
    my($self) = @_;
    # Returns true if self is general realm.
    return $self->get_general->get('id') eq $self->get('id') ? 1 : 0;
}

sub new {
    my($proto, $owner, $req) = @_;
    # If the realm has an I<owner>, it will be saved.  If it
    # has an I<owner_id> or I<owner_name>, the owner will be loaded first.
    # The owner must exist.
    Bivio::Die->die("must have owner or call type explicitly")
        unless $owner;
    if (ref($owner)) {
	return $proto->new(lc($owner->get_name()), $req)
	    if $proto->is_blessed($owner, 'Bivio::Auth::RealmType');
    }
    else {
#TODO: Deprecate default names to be special, e.g. =user
        Bivio::Die->die('cannot create model without request')
	    unless ref($req);
	my($g) = $proto->get_general;
	return $g
	    if $g->get('id') eq $owner || $owner eq 'general';
	$owner = Bivio::Biz::Model->new($req, 'RealmOwner')
	     ->unauth_load_by_id_or_name_or_die($owner);
    }
    return $owner->clone
	if UNIVERSAL::isa($owner, __PACKAGE__);
    return _new($proto, $owner, $req);
}

sub _new {
    my($proto, $owner, $req) = @_;
    # Create a new instance.  If I<owner> is undef, a GENERAL realm
    # is created.

    # Instantiate and initialize with/out owner
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {};
    unless ($owner) {
	# If there is no owner, then permissions already retrieved from
	# database.  Set "id" to realm_type.
	my($type) = $_RT->GENERAL;
	$self->put(id => $type->as_int, type => $type);
	return $self;
    }

    my($type) = $owner->get('realm_type');
    Bivio::Die->die($owner, ': owner not a Model::RealmOwner')
	    unless UNIVERSAL::isa($owner, 'Bivio::Biz::Model::RealmOwner');

#TODO: Change this so everyone knows realm_id?
    my($id) = $owner->get('realm_id');
    Bivio::Die->die($id, ': owner must have valid id (must be loaded)')
		unless $id;
    $self->put(owner => $owner, id => $id,
	    owner_name => $owner->get('name'),
	    type => $type);
    return $self;
}

sub _perm_set_from_all {
    my($permissions) = @_;
    # Calculate the sum of all given permissions.
    my($perm_set) = Bivio::Auth::PermissionSet->get_min;
    foreach my $perms (@$permissions) {
 	$perm_set |= $perms;
    }
    return $perm_set;
}

1;
