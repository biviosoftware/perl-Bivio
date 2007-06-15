# Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::Realm;
use strict;
$Bivio::Auth::Realm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Auth::Realm::VERSION;

=head1 NAME

Bivio::Auth::Realm - abstract class defining access to resources

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Auth::Realm;
    Bivio::Auth::Realm->new();

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Auth::Realm::ISA = qw(Bivio::Collection::Attributes);

=head1 DESCRIPTION

C<Bivio::Auth::Realm> defines the authorization policy for
L<Bivio::Auth::Role|Bivio::Auth::Role> and
L<Bivio::Agent::Task|Bivio::Agent::Task>.
A task is authorized by
L<can_user_execute_task|"can_user_execute_task">.

Subclasses define the actual authorization policies.

=head1 ATTRIBUTES

=over 4

=item id : string

Primary id of the owner or the RealmType as an int.

=item owner : Bivio::Biz::Model::RealmOwner

The particular instance of this realm.  Only used in the case of
clubs and users.  General does not have an owner.

=item owner_name : string

Named retrieved from realm owner.  Not defined for the general realm.
Always use this value instead of owner-E<gt>get('name').

=item type : Bivio::Auth::RealmType

Type of this realm.

=back

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::IO::ClassLoader;
use Bivio::HTML;
use Bivio::Auth::Permission;
use Bivio::Auth::PermissionSet;
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Auth::Support;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_INITIALIZED) = 0;
my($_GENERAL);
my($_PI) = Bivio::Type->get_instance('PrimaryId');
my(@_USED_ROLES) = grep($_ ne Bivio::Auth::Role->UNKNOWN(),
	    Bivio::Auth::Role->get_list);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Auth::Realm

=head2 static new(Bivio::Biz::Model owner) : Bivio::Auth::Realm

=head2 static new(string owner_id, Bivio::Agent::Request req) : Bivio::Auth::Realm

=head2 static new(string owner_name, Bivio::Agent::Request req) : Bivio::Auth::Realm

If the realm has an I<owner>, it will be saved.  If it
has an I<owner_id> or I<owner_name>, the owner will be loaded first.
The owner must exist.

=cut

sub new {
    my($proto, $owner, $req) = @_;
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

=head1 METHODS

=cut

=for html <a name="as_string"></a>

=head2 as_string() : string

Pretty prints the realm.

=cut

sub as_string {
    my($self) = @_;
    my($owner) = $self->unsafe_get('owner');
    return ref($self)
	. '['
        . join(
	    ',',
	    $self->get('type')->get_name,
	    $owner ? $self->unsafe_get('owner_name', 'id') : (),
        ) . ']';
}

=for html <a name="can_user_execute_task"></a>

=head2 can_user_execute_task(Bivio::Agent::Task task, Bivio::Agent::Request req) : boolean

Returns true if I<auth_user> of I<req> can execute I<task>.

=cut

sub can_user_execute_task {
    my($self, $task, $req) = @_;

    # Is the task defined in the right realm?
    unless ($self->get('type') eq $task->get('realm_type')) {
	_trace($task->get('id'), ': no such task in ', $self->get('type'))
	    if $_TRACE;
	return 0;
    }
    return $self->does_user_have_permissions($task->get('permission_set'), $req);
}

=for html <a name="do_default"></a>

=head2 static do_default(code_ref op, Bivio::Agent::Request req)

Iterates all default realms, setting realms to default user.

=cut

sub do_default {
    my($proto, $op, $req) = @_;
    my($realm, $user) = $req->get(qw(auth_realm auth_user));
    $req->set_user('user');
    my($die) = Bivio::Die->catch(sub {
	foreach my $r (
	    grep(!$_->eq_unknown, Bivio::Auth::RealmType->get_list)
        ) {
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

=for html <a name="does_user_have_permissions"></a>

=head2 does_user_have_permissions(Bivio::Auth::PermissionSet perms, Bivio::Agent::Request req) : boolean

Does req.auth_user have I<perms> in this realm.

=cut

sub does_user_have_permissions {
    my($self, $perms, $req) =  @_;
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

=for html <a name="equals"></a>

=head2 equals(UNIVERSAL that) : boolean

Returns true if I<self> is identical I<that>.

=cut

sub equals {
    my($self, $that) = @_;
    return ref($self) eq ref($that) && $self->get('id') eq $that->get('id')
	? 1 : 0;
}

=for html <a name="format_email"></a>

=head2 format_email() : string

How to mail to this realm.

=cut

sub format_email {
    my($self) = @_;
    # This is more than caching. It allows for overriding.
    my($email) = $self->unsafe_get('_email');
    return $email if $email;

    # Compute and cache (since we are checking anyway)
    $email = $self->get('owner')->get_request->format_email(
	    $self->get('owner_name'));
    $self->put(_email => $email);
    return $email;
}

=for html <a name="format_file"></a>

=head2 format_file() : string

Returns the root of the file server.

=cut

sub format_file {
    my($self) = @_;
    # This is more than caching. It allows to override this value.
    my($file) = $self->unsafe_get('_file');
    return $file if $file;

    # Compute and cache (since we are checking anyway)
    $file = $self->get('owner_name');
    $self->put(_file => $file);
    return $file;
}

=for html <a name="format_uri"></a>

=head2 format_uri() : string

Returns the "home" of this realm, i.e. just its name.
Only works for realms with owners.

=cut

sub format_uri {
    my($self) = @_;
    # This is more than caching. It allows to override this value.
    my($uri) = $self->unsafe_get('_uri');
    return $uri if $uri;

    # Compute and cache (since we are checking anyway)
    $uri = $self->get('owner')->format_uri();
    $self->put(_uri => $uri);
    return $uri;
}

=for html <a name="get_default_id"></a>

=head2 get_default_id() : string

Returns the default id for this realm.

=cut

sub get_default_id {
    my($self) = @_;
    return $self->get('type')->as_int;
}

=for html <a name="get_default_name"></a>

=head2 get_default_name() : string

Returns the owner name used for the three default realms (general, club, user).

=cut

sub get_default_name {
    my($self) = @_;
    return lc($self->get('type')->get_name);
}

=for html <a name="get_general"></a>

=head2 get_general() : Bivio::Auth::Realm

Returns the singleton instance of the GENERAL realm.

=cut

sub get_general {
    return $_GENERAL ||= _new(shift(@_));
}

=for html <a name="get_type"></a>

=head2 static get_type() : Bivio::Auth::RealmType

Returns the RealmType for this realm.

B<DEPRECATED>.

=cut

sub get_type {
    my($proto) = @_;
    # Get the type from the instance itself otherwise
    # just from class.
    return $proto->get('type') if ref($proto);
    Bivio::Die->die($proto, ': unknown realm class');
}

=for html <a name="has_owner"></a>

=head2 has_owner() : boolean

Returns true if has I<owner> (same as not is_default).

=cut

sub has_owner {
    return shift->is_default ? 0 : 1;
}

=for html <a name="id_from_any"></a>

=head2 static id_from_any(any realm_or_id) : string

=head2 id_from_any(any realm_or_id) : string

Returns the realm_id from I<realm_or_id>.  Can be a realm_id,
model with realm_id, instance, or self.

=cut

sub id_from_any {
    my($proto) = shift;
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

=for html <a name="is_default"></a>

=head2 is_default() : boolean

Returns true if the realm is one of the default realms (general, user, club).

=cut

sub is_default {
    my($self) = @_;
    return 1 if $self->get('type') == Bivio::Auth::RealmType->GENERAL;
    return $self->get('owner')->is_default;
}

=for html <a name="is_default_id"></a>

=head2 static is_default_id(string id) : boolean

Returns true if I<id> is a default realm_id.

=cut

sub is_default_id {
    my(undef, $id) = @_;
    Bivio::Die->die($id, ': not an id')
        unless defined($id) && $id !~ /\D/;
    # At least info is in one place...
    return $id < $_PI->get_min ? 1 : 0;
}

=for html <a name="is_general"></a>

=head2 is_general() : boolean

Returns true if self is general realm.

=cut

sub is_general {
    my($self) = @_;
    return $self->get_general->get('id') eq $self->get('id') ? 1 : 0;
}

#=PRIVATE METHODS

# _new($proto, $owner, $req) : Bivio::Auth::Realm
#
# Create a new instance.  If I<owner> is undef, a GENERAL realm
# is created.
#
sub _new {
    my($proto, $owner, $req) = @_;

    # Instantiate and initialize with/out owner
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {};
    unless ($owner) {
	# If there is no owner, then permissions already retrieved from
	# database.  Set "id" to realm_type.
	my($type) = Bivio::Auth::RealmType->GENERAL();
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

# _perm_set_from_all(arrayref permissions) : Bivio::Auth::PermissionSet
#
# Calculate the sum of all given permissions.
#
sub _perm_set_from_all {
    my($permissions) = @_;
    my($perm_set) = Bivio::Auth::PermissionSet->get_min;
    foreach my $perms (@$permissions) {
 	$perm_set |= $perms;
    }
    return $perm_set;
}

=head1 COPYRIGHT

Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
