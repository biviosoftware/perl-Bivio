# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmUser;
use strict;
$Bivio::Biz::Model::RealmUser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::RealmUser::VERSION;

=head1 NAME

Bivio::Biz::Model::RealmUser - interface to realm_user_t SQL table

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmUser;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmUser::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmUser> is the create, read, update,
and delete interface to the C<realm_user_t> table.

=cut

#=IMPORTS
# also uses User model
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Auth::RoleSet;
use Bivio::Die;
use Bivio::SQL::Connection;
use Bivio::Type::DateTime;
use Bivio::Type::RealmName;

#=VARIABLES
my($_ACTIVE_ROLES) = '';
Bivio::Auth::RoleSet->set(\$_ACTIVE_ROLES,
	Bivio::Auth::Role::GUEST(),
	Bivio::Auth::Role::MEMBER(),
	Bivio::Auth::Role::ACCOUNTANT(),
	Bivio::Auth::Role::ADMINISTRATOR(),
	);
my($_MEMBER_ROLES) = '';
Bivio::Auth::RoleSet->set(\$_MEMBER_ROLES,
	Bivio::Auth::Role::MEMBER(),
	Bivio::Auth::Role::ACCOUNTANT(),
	Bivio::Auth::Role::ADMINISTRATOR(),
       );

my($_MEMBER_OR_WITHDRAWN_ROLES) = '';
Bivio::Auth::RoleSet->set(\$_MEMBER_OR_WITHDRAWN_ROLES,
	Bivio::Auth::Role::WITHDRAWN(),
	Bivio::Auth::Role::MEMBER(),
	Bivio::Auth::Role::ACCOUNTANT(),
	Bivio::Auth::Role::ADMINISTRATOR(),
       );
my($_IS_SOLE_ADMIN_QUERY) = "SELECT count(*)
	    FROM realm_owner_t, realm_user_t
	    WHERE realm_user_t.realm_id = ?
	    AND user_id != ?
	    AND role = "
	    .Bivio::Auth::Role::ADMINISTRATOR->as_sql_param."
	    AND realm_user_t.user_id = realm_owner_t.realm_id
	    AND realm_owner_t.name NOT LIKE '"
	    .Bivio::Type::RealmName->OFFLINE_PREFIX."\%'";

=head1 CONSTANTS

=cut

=for html <a name="VALID_ACTIVE_ROLES"></a>

=head2 VALID_ACTIVE_ROLES : string

Value is a L<Bivio::Auth::RoleSet|Bivio::Auth::RoleSet>
includes Guest, Member, Accountant, and Administrator.

=cut

sub VALID_ACTIVE_ROLES {
    return $_ACTIVE_ROLES;
}

=for html <a name="MEMBER_ROLES"></a>

=head2 MEMBER_ROLES : string

Value is a L<Bivio::Auth::RoleSet|Bivio::Auth::RoleSet>.

=cut

sub MEMBER_ROLES {
    return $_MEMBER_ROLES;
}

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<creation_date_time> if not set. Defaults the role to the honorific's
role if not set.

=cut

sub create {
    my($self, $values) = @_;
    $values->{creation_date_time} ||= Bivio::Type::DateTime->now;
    $values->{role} ||= $values->{honorific}->get_role;
    return $self->SUPER::create($values);
}

=for html <a name="execute_auth_user"></a>

=head2 static execute_auth_user(Bivio::Agent::Request req)

Loads this realm for this auth user.

=cut

sub execute_auth_user {
    my($proto, $req) = @_;
    my($user) = $req->get('auth_user');
    Bivio::Die->die('no auth_user') unless $user;
    $proto->new($req)->load(user_id => $user->get('realm_id'));
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_user_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            user_id => ['User.user_id', 'PRIMARY_KEY'],
            role => ['RealmRole.role', 'NOT_NULL'],
	    honorific => ['Honorific', 'NOT_ZERO_ENUM'],
	    creation_date_time => ['DateTime', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
#TODO: SECURITY: If user_id known, does that mean can get to all user's info?
	other => [
	    # User_1 is the realm, if the realm_type is a user.
	    [qw(realm_id Club.club_id User_1.user_id RealmOwner_1.realm_id)],
	    # User_2 is the the "realm_user"
	    [qw(user_id User_2.user_id RealmOwner_2.realm_id)],
	],
    };
}

=for html <a name="is_auth_user"></a>

=head2 is_auth_user() : boolean

=head2 static is_auth_user(Bivio::Biz::Model model, string model_prefix) : boolean

Returns true if the current row is the request's auth_user.

=cut

sub is_auth_user {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    my($auth_user) = $model->get_request->get('auth_user');
    return 0 unless $auth_user;
    return $model->get($model_prefix.'user_id')
	    eq $auth_user->get('realm_id') ? 1 : 0;
}

=for html <a name="is_guest"></a>

=head2 is_guest() : boolean

=head2 static is_guest(Bivio::Biz::Model model, string model_prefix) : boolean

Returns true if the user is a GUEST.

In the second form, I<model> is used to get the values, not I<self>.
List Models can declare a method of the form:

    sub is_guest {
	my($self) = shift;
	Bivio::Biz::Model::RealmUser->format($self, 'RealmUser.');
    }

=cut

sub is_guest {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    return $model->get($model_prefix.'role') ==
	    Bivio::Auth::Role::GUEST() ? 1 : 0;
}

=for html <a name="is_member"></a>

=head2 is_member() : boolean

=head2 static is_member(Bivio::Biz::Model model, string model_prefix) : boolean

Returns true if the user is a member or above, i.e. I<role> must
be MEMBER, ACCOUNT, or ADMINISTRATOR.

In the second form, I<model> is used to get the values, not I<self>.
List Models can declare a method of the form:

    sub is_member {
	my($self) = shift;
	Bivio::Biz::Model::RealmUser->format($self, 'RealmUser.');
    }

=cut

sub is_member {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    return Bivio::Auth::RoleSet->is_set(\$_MEMBER_ROLES,
	    $model->get($model_prefix.'role'));
}

=for html <a name="is_member_or_guest"></a>

=head2 is_member_or_guest() : boolean

=head2 static is_member_or_guest(Bivio::Biz::Model model, string model_prefix) : boolean

Is this a member, accountant, admin, or a guest?

=cut

sub is_member_or_guest {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    return unless Bivio::Auth::RoleSet->is_set(\$_ACTIVE_ROLES,
	    $model->get($model_prefix.'role'));
}

=for html <a name="is_member_or_withdrawn"></a>

=head2 is_member_or_withdrawn() : boolean

=head2 static is_member_or_withdrawn(Bivio::Biz::Model model, string model_prefix) : boolean

Returns true if the user is a member or above, i.e. I<role> must
be WITHDRAWN, MEMBER, ACCOUNT, or ADMINISTRATOR.

=cut

sub is_member_or_withdrawn {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    return Bivio::Auth::RoleSet->is_set(\$_MEMBER_OR_WITHDRAWN_ROLES,
	    $model->get($model_prefix.'role'));
}

=for html <a name="is_sole_admin"></a>

=head2 is_sole_admin() : boolean

=head2 static is_sole_admin(Bivio::Biz::Model model, string model_prefix) : boolean

Returns true if this is the only online ADMINISTRATOR left in the realm.

=cut

sub is_sole_admin {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Check to see if an admin at all.  This avoids a db query for most
    # realm users.
    return 0 unless $model->get($model_prefix.'role')
	    == Bivio::Auth::Role::ADMINISTRATOR();
    return _cache_in_request($proto, $model, $model_prefix,
	    $_IS_SOLE_ADMIN_QUERY) ? 0 : 1;
}

=for html <a name="unauth_load_user_or_die"></a>

=head2 unauth_load_user_or_die() : Bivio::Biz::Model::User

Loads the user for this RealmUser.

=cut

sub unauth_load_user_or_die {
    my($self) = @_;
    return Bivio::Biz::Model->new($self->get_request, 'User')
	    ->unauth_load_or_die(user_id => $self->get('user_id'));
}

#=PRIVATE METHODS

# _cache_in_request(proto, Bivio::Biz::Model model, string model_prefix, string query) : boolean
#
# Computes the boolean $query, unless it already is on the request.
# Must accept a [realm, user] as params.
#
sub _cache_in_request {
    my($proto, $model, $model_prefix, $query) = @_;
    my($req) = $model->get_request;
    my($realm, $user) = $model->get(
	    $model_prefix.'realm_id', $model_prefix.'user_id');
    return $req->get_if_exists_else_put(
	    (caller(1))[3].$realm.'-'.$user =>
	    sub {
		return Bivio::SQL::Connection->execute_one_row(
			$query, [$realm, $user])->[0] ? 1 : 0;
	    });
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
