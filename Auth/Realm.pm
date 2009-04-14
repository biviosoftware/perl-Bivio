# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::Realm;
use strict;
use Bivio::Base 'Collection.Attributes';
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
my($_PI) = b_use('Type.PrimaryId');
my(@_USED_ROLES) = b_use('Auth.Role')->get_non_zero_list;
my($_RT) = b_use('Auth.RealmType');
my($_PS) = b_use('Auth.PermissionSet');
my($_RO) = b_use('Model.RealmOwner');
my($_S) = b_use('Auth.Support');
my($_M) = b_use('Biz.Model');

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
    return _do_default(get_non_zero_list => @_);
}

sub do_any_group_default {
    return _do_default(get_any_group_list => @_);
}

sub does_user_have_permissions {
    my($self, $perms, $req) =  @_;
    # Does req.auth_user have I<perms> in this realm.
    $perms = ${$_PS->from_array($perms)}
	if ref($perms) eq 'ARRAY';
    my($fields) = $self->[$_IDI];
    return $_S->task_permission_ok(
	_perm_set_from_all([map({
	    my($auth_role) = $_;
	    unless (defined($fields->{$auth_role})) {
		$fields->{$auth_role} = $_S->load_permissions(
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
    b_die($proto, ': unknown realm class');
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
	? __PACKAGE__->is_blessed($realm_or_id)
        ? $realm_or_id->get('id')
	: $_M->is_blessed($realm_or_id)
	? $realm_or_id->get('realm_id')
        : b_die($realm_or_id, ': unhandled reference type')
	: $_PI->is_specified($realm_or_id) || $proto->is_default_id($realm_or_id)
	? $realm_or_id
	: b_die($realm_or_id, ': not a PrimaryId');
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
    b_die("must have owner or call type explicitly")
        unless $owner;
    if (ref($owner)) {
	return $proto->new(lc($owner->get_name), $req)
	    if $_RT->is_blessed($owner);
    }
    else {
#TODO: Deprecate default names to be special, e.g. =user
        b_die('cannot create model without request')
	    unless ref($req);
	my($g) = $proto->get_general;
	return $g
	    if $g->get('id') eq $owner || $owner eq 'general';
	$owner = $_RO->new($req)->unauth_load_by_id_or_name_or_die($owner);
    }
    return $owner->clone
	if __PACKAGE__->is_blessed($owner);
    return _new($proto, $owner, $req);
}

sub owner_name_equals {
    my($self, $name) = @_;
    return ($self->unsafe_get('owner_name') || '') eq $name ? 1 : 0;
}

sub _do_default {
    my($list_method, $proto, $op, $req) = @_;
    $req->with_user(user => sub {
	foreach my $r ($_RT->$list_method()) {
	    last
		unless $req->with_realm(
		    $r->get_name,
		    sub {$op->($req->get('auth_realm'))},
		);
	}
	return;
    });
    return;
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
    b_die($owner, ': owner not a Model::RealmOwner')
        unless $_RO->is_blessed($owner);

#TODO: Change this so everyone knows realm_id?
    my($id) = $owner->get('realm_id');
    b_die($id, ': owner must have valid id (must be loaded)')
	unless $id;
    $self->put(
	owner => $owner,
	id => $id,
	owner_name => $owner->get('name'),
	type => $type,
    );
    return $self;
}

sub _perm_set_from_all {
    my($permissions) = @_;
    # Calculate the sum of all given permissions.
    my($perm_set) = $_PS->get_min;
    foreach my $perms (@$permissions) {
 	$perm_set |= $perms;
    }
    return $perm_set;
}

1;
