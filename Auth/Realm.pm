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

L<Bivio::Type::Attributes>

=cut

use Bivio::Type::Attributes;
@Bivio::Auth::Realm::ISA = qw(Bivio::Type::Attributes);

=head1 DESCRIPTION

C<Bivio::Auth::Realm> defines the authorization policy for
L<Bivio::Auth::Role|Bivio::Auth::Role> and
L<Bivio::Agent::Task|Bivio::Agent::Task>.
A role is authorized by L<get_user_role|"get_user_role">.
A task is authorized by
L<can_role_execute_task|"can_role_execute_task">.

Subclasses define the actual authorization policies.

=cut

#=IMPORTS
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Carp ();
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
# Create class names from REALM_TYPE names.
my(%_CLASS_TO_TYPE) = map {
    my($class) = lc($_->as_string);
    $class =~ s/(^|_)(\w)/\u$2/g;
    ("Bivio::Auth::Realm::$class", $_);
} Bivio::Auth::RealmType->get_list;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Auth::Realm

=head2 static new(hash_ref task_id_to_role, Bivio::Biz::Model owner, string owner_class, string owner_id_field) : Bivio::Auth::Realm

If the realm has an I<owner>, it will be stored here.

=cut

sub new {
    my($proto, $task_id_to_role, $owner, $owner_class, $owner_id_field) = @_;
    my($self) = &Bivio::Type::Attributes::new($proto,
	    {task_id_to_role => $task_id_to_role});
    return $self
	    unless defined($owner_class);
    Carp::croak('owner not specified or not a ', $owner_class)
	    unless UNIVERSAL::isa($owner, $owner_class);
    my($owner_id) = $owner->get($owner_id_field);
    $owner_id || Carp::croak('owner must have valid id (must be loaded)');
    $self->put(owner => $owner, owner_id => $owner_id,
	    owner_id_field => $owner_id_field,
	   owner_name => $owner->get('name'));
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
    my($owner_name, $owner_id) = $self->unsafe_get('owner_name', 'owner_id');
    return ref($self) . (defined($owner_name)
	    ? ('('.$owner_name.','.$owner_id.')'): '');
}

=for html <a name="can_role_execute_task"></a>

=head2 can_role_execute_task(Bivio::Auth::Role auth_role, Bivio::Agent::TaskId task_id, Bivio::Agent::Request req) : boolean

Returns true if I<auth_role> can execute I<task_id>.

=cut

sub can_role_execute_task {
    my($self, $auth_role, $task_id, $req) = @_;
    # $req will be used when we get privileges from the database
    my($map) = $self->get('task_id_to_role');
    unless ($map->{$task_id}) {
	&_trace($task_id, ': task not defined for realm ', $self->get_type);
	return 0;
    }
    unless ($map->{$task_id}->as_int <= $auth_role->as_int) {
	&_trace($task_id, ': required ', $map->{$task_id},
		', but got role ',  $auth_role) if $_TRACE;
	return 0;
    }
    return 1;
}

=for html <a name="get_type"></a>

=head2 static get_type() : Bivio::Auth::RealmType

Returns the RealmType for this realm.

=cut

sub get_type {
    my($proto) = @_;
    my($class) = ref($proto) || $proto;
    Carp::croak("$class: unknown realm class")
	    unless exists($_CLASS_TO_TYPE{$class});
    return $_CLASS_TO_TYPE{$class};
}

=for html <a name="get_user_role"></a>

=head2 abstract get_user_role(Bivio::Biz::PropertyModel::User auth_user, Bivio::Agent::Request req) : Bivio::Auth::Role

Returns the role the (to be) authenticated user plays in this realm.

=cut

sub get_user_role {
    my($self, $auth_user, $req) = @_;
    my($user_id) = $auth_user && $auth_user->get('user_id');
    return Bivio::Auth::Role::ANONYMOUS
	    unless $user_id;
    my($owner) = $self->unsafe_get('owner');
    return Bivio::Auth::Role::USER()
	    unless $owner;
    my($realm_user) = Bivio::Biz::PropertyModel::RealmUser->new($req);
    return Bivio::Auth::Role::USER
	    unless $realm_user->unauth_load(
		    realm_id => $self->get('owner_id'),
		    user_id => $user_id);
    return Bivio::Auth::Role->from_int($realm_user->get('role'));
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
