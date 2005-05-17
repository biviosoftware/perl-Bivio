# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
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
#Avoid circular import: See code in _initialize
use Bivio::Auth::Permission;
use Bivio::Auth::PermissionSet;
use Bivio::Auth::Realm::General;
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Auth::Support;
use Bivio::IO::Trace;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;
my($_INITIALIZED) = 0;
use vars qw($_TRACE);
Bivio::IO::Trace->register;
# Create class names from REALM_TYPE names.
my($_CLASS_TO_TYPE) = {map {
    my($class) = lc($_->get_name);
    $class =~ s/(^|_)(\w)/\u$2/g;
    # Don't need to "use" these modules, because don't actually
    # reference the class--just a name here.
    ("Bivio::Auth::Realm::$class", $_);
} Bivio::Auth::RealmType->get_list};
my($_TYPE_TO_CLASS) = {reverse(%$_CLASS_TO_TYPE)};
# Maps realm types to permission sets
my(@_USED_ROLES) = grep($_ ne Bivio::Auth::Role::UNKNOWN(),
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
    $_INITIALIZED || _initialize();
    if ($proto eq __PACKAGE__) {
	Bivio::Die->die("must have owner or call type explicitly")
		    unless $owner;
	unless (ref($owner)) {
	    Bivio::Die->die('cannot create model without request')
			unless ref($req);
	    $owner = Bivio::Biz::Model->new($req, 'RealmOwner')
		    ->unauth_load_by_id_or_name_or_die($owner);
	}
	my($realm_type) = $owner->get('realm_type');
	return Bivio::Auth::Realm::Club->new($owner)
		if $realm_type == Bivio::Auth::RealmType->CLUB();
	return Bivio::Auth::Realm::User->new($owner)
		if $realm_type == Bivio::Auth::RealmType->USER();
	return Bivio::Auth::Realm::General->get_instance
		if $realm_type == Bivio::Auth::RealmType->GENERAL();
	Bivio::Die->die($realm_type, ": unknown realm type");
    }

    # Instantiate and initialize with/out owner
    my($self) = &Bivio::Collection::Attributes::new($proto);
    $self->[$_IDI] = {};
    unless ($owner) {
	# If there is no owner, then permissions already retrieved from
	# database.  Set "id" to realm_type.
	my($type) = $_CLASS_TO_TYPE->{ref($self)};
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

=head1 METHODS

=cut

=for html <a name="as_string"></a>

=head2 as_string() : string

Pretty prints the realm.

=cut

sub as_string {
    my($self) = @_;
    my($owner_name, $id) = $self->unsafe_get('owner_name', 'id');
    return ref($self) . (defined($owner_name)
	    ? ('('.$owner_name.','.$id.')'): '');
}

=for html <a name="can_user_execute_task"></a>

=head2 can_user_execute_task(Bivio::Agent::Task task, Bivio::Agent::Request req) : boolean

Returns true if I<auth_user> of I<req> can execute I<task>.

=cut

sub can_user_execute_task {
    my($self, $task, $req) = @_;
    my($auth_role) = $req->get_auth_role($self);
    my($realm_type, $required) = $task->get('realm_type', 'permission_set');

    # Is the task defined in the right realm?
    unless ($self->get('type') eq $realm_type) {
	_trace($task->get('id'), ': no such task in ', $self->get('type'))
		if $_TRACE;
	return 0;
    }

    # Load the permissions and cache
    my($fields) = $self->[$_IDI];
    $fields->{$auth_role} = Bivio::Auth::Support->load_permissions(
	    $self, $auth_role, $req)
	    unless defined($fields->{$auth_role});

    return Bivio::Auth::Support->task_permission_ok(
	    $fields->{$auth_role}, $required, $req);
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
    return Bivio::Auth::Realm::General->get_instance();
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
    Bivio::Die->die($proto, ': unknown realm class')
	    unless exists($_CLASS_TO_TYPE->{$proto});
    return $_CLASS_TO_TYPE->{$proto};
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
    # At least info is in one place...
    return $id < Bivio::Type::PrimaryId->get_min ? 1 : 0;
}

#=PRIVATE METHODS

# _initialize()
#
# Loads the RealmType classes.
#
sub _initialize {
    return if $_INITIALIZED;
    $_INITIALIZED = 1;
    foreach my $t ('GENERAL', 'USER', 'CLUB') {
	my($rt) = Bivio::Auth::RealmType->$t();
	my($rc) = $_TYPE_TO_CLASS->{$rt};
	Bivio::IO::ClassLoader->simple_require($rc);
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
