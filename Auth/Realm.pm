# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Auth::Realm;
use strict;
$Bivio::Auth::Realm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Auth::Realm - abstract class defining access to resources

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
Always use this value and owner-E<gt>get('name').

=item type : Bivio::Auth::RealmType

Type of this realm.

=back

=cut

#=IMPORTS
use Bivio::IO::ClassLoader;
use Bivio::HTML;
#Avoid circular import: See code in _initialize
use Bivio::Auth::Permission;
use Bivio::Auth::PermissionSet;
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::IO::Trace;
use Carp ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_INITIALIZED) = 0;
use vars qw($_TRACE);
Bivio::IO::Trace->register;
# Create class names from REALM_TYPE names.
my(%_CLASS_TO_TYPE) = map {
    my($class) = lc($_->get_name);
    $class =~ s/(^|_)(\w)/\u$2/g;
    # Don't need to "use" these modules, because don't actually
    # reference the class--just a name here.
    ("Bivio::Auth::Realm::$class", $_);
} Bivio::Auth::RealmType->get_list;
my(%_TYPE_TO_CLASS) = reverse(%_CLASS_TO_TYPE);
# Maps realm types to permission sets
my(%_DEFAULT_PERMISSION_SET) = ();

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
	Carp::croak("no owner") unless $owner;
	unless (ref($owner)) {
	    Bivio::IO::Alert->die('cannot create model without request')
			unless ref($req);
	    my($o) = Bivio::Biz::Model::RealmOwner->new($req);
	    Bivio::IO::Alert->die($owner, ': realm_id not found')
			unless $o->unauth_load(($owner =~ /^\d+$/
				? 'realm_id' : 'name') => $owner);
	    $owner = $o;
	}
	my($realm_type) = $owner->get('realm_type');
	return Bivio::Auth::Realm::Club->new($owner)
		if $realm_type == Bivio::Auth::RealmType::CLUB();
	return Bivio::Auth::Realm::User->new($owner)
		if $realm_type == Bivio::Auth::RealmType::USER();
	Bivio::IO::Alert->die($realm_type, ": unknown realm type");
    }

    # Instantiate and initialize with/out owner
    my($self) = &Bivio::Collection::Attributes::new($proto);
    unless ($owner) {
	# If there is no owner, then permissions already retrieved from
	# database.  Set "id" to realm_type.
	my($type) = $_CLASS_TO_TYPE{ref($self)};
	$self->{$_PACKAGE} = $_DEFAULT_PERMISSION_SET{$type};
	$self->put(id => $type->as_int, type => $type);
	return $self;
    }

    my($type) = $owner->get('realm_type');
    $self->{$_PACKAGE} = {
        default_permission_set => $_DEFAULT_PERMISSION_SET{$type},
    };
    Carp::croak('not a Model::RealmOwner') unless UNIVERSAL::isa($owner,
            'Bivio::Biz::Model::RealmOwner');

#TODO: Change this so everyone knows realm_id?
    my($id) = $owner->get('realm_id');
    Carp::croak('owner must have valid id (must be loaded)')
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
	&_trace($task->get('id'), ': no such task in ', $self->get('type'));
	return 0;
    }


    # Load the realm_role permissions
    my($fields) = $self->{$_PACKAGE};
    my($privileges);
    unless (defined($privileges = $fields->{$auth_role})) {
	my($rr) = Bivio::Biz::Model::RealmRole->new($req);
	# Cache the permissions for later use
	$privileges = $fields->{$auth_role}
		= $rr->unauth_load(realm_id => $self->get('id'),
			role => $auth_role)
			? $rr->get('permission_set')
			: $fields->{default_permission_set}->{$auth_role};
    }

    # Does this role have all the required permission?
    unless (($privileges & $required) eq $required) {
	&_trace($task->get('id'), ': insufficient privileges');
	return 0;
    }
    return 1;
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
    $email = $self->get('owner_name').'@'
	    .$self->get('owner')->get_request->get('mail_host');
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
    Carp::croak("$proto: unknown realm class")
	    unless exists($_CLASS_TO_TYPE{$proto});
    return $_CLASS_TO_TYPE{$proto};
}

#=PRIVATE METHODS

# _initialize()
#
# Initializes %_DEFAULT_PERMISSION_SET for all realm types from the database.
#
sub _initialize {
    $_INITIALIZED && return;
    # Avoid circular import
    Bivio::IO::ClassLoader->simple_require('Bivio::Biz::Model::RealmOwner');
    Bivio::IO::ClassLoader->simple_require('Bivio::Biz::Model::RealmRole');

    my($rr) = Bivio::Biz::Model::RealmRole->new();
    my(@roles) = grep($_ ne Bivio::Auth::Role::UNKNOWN(),
	    Bivio::Auth::Role->get_list);
#DBCACHE: realm_role_t
    foreach my $t ('GENERAL', 'USER', 'CLUB') {
	my($rt) = Bivio::Auth::RealmType->$t();
	my($rti) = $rt->as_int;
	my($rc) = $_TYPE_TO_CLASS{$rt};
	Bivio::IO::ClassLoader->simple_require($rc);
	my($dp) = $_DEFAULT_PERMISSION_SET{$rt} = {};
	foreach my $r (@roles) {
	    die($rt->as_string, ': unable to load default permissions for ',
		    $r->as_string)
		    unless $rr->unauth_load(realm_id => $rti, role => $r);
	    $dp->{$r} = $rr->get('permission_set');
	}
    }
    $_INITIALIZED = 1;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
