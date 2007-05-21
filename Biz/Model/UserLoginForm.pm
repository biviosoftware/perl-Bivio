# Copyright (c) 1999-2002 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::UserLoginForm;
use strict;
$Bivio::Biz::Model::UserLoginForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::UserLoginForm::VERSION;

=head1 NAME

Bivio::Biz::Model::UserLoginForm - authenticates user via form

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::UserLoginForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::UserLoginForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::UserLoginForm> is used to login which changes the
cookie.  Modules which "login" users should call <tt>execute</tt>
with the new realm_owner.

A user is logged in if his PASSWORD_FIELD is set in the cookie.  We keep the
user_id in the cookie so we can track logged out users.

=cut

=head1 CONSTANTS

=cut

=for html <a name="SUPER_USER_FIELD"></a>

=head2 SUPER_USER_FIELD : string

B<DEPRECATED>:
L<Bivio::Biz::Model::AdmSubstituteUserForm::SUPER_USER_FIELD|Bivio::Biz::Model::AdmSubstituteUserForm/SUPER_USER_FIELD>

=cut

sub SUPER_USER_FIELD {
    Bivio::IO::Alert->warn_deprecated(
	'use Bivio::Biz::Model::AdmSubstituteUserForm->SUPER_USER_FIELD');
    return shift->get_instance('AdmSubstituteUserForm')->SUPER_USER_FIELD;
}

=for html <a name="PASSWORD_FIELD"></a>

=head2 PASSWORD_FIELD : string

Returns the cookie key for the encrypted password field.

=cut

sub PASSWORD_FIELD {
    return 'p';
}

=for html <a name="USER_FIELD"></a>

=head2 USER_FIELD : string

Returns the cookie key for the super user value.

=cut

sub USER_FIELD {
    return 'u';
}

#=IMPORTS
use Bivio::Agent::HTTP::Cookie;
use Bivio::Auth::RealmType;
use Bivio::Auth::RealmType;
use Bivio::IO::Trace;
use Bivio::Type::Password;
use Bivio::Type::UserState;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
Bivio::Agent::HTTP::Cookie->register(__PACKAGE__);

=head1 METHODS

=cut

=for html <a name="assert_can_substitute_user"></a>

=head2 assert_can_substitute_user()

Dies unless user is super user.  Subclasses can override this method to relax
this constraint.

=cut

sub assert_can_substitute_user {
    my($proto, $realm, $req) = @_;
    Bivio::Die->die('not a super user: ', $req)
	unless $req->is_super_user;
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok() : boolean

Sets the realm to logged in user.  If I<realm_owner> is C<undef>,
is same as logout.

Note: If you call this method explicitly (via I<execute>), the cookie
will be checked.  Don't call this method unless you want the cookie
set.

If call this method with a I<login>, but no I<realm_owner>,
I<realm_owner> will be loaded, a die will happen if not found.

=cut

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    my($realm) = $self->unsafe_get('validate_called')
	? $self->get('realm_owner')
        : $self->has_keys('realm_owner') ? _assert_realm($self)
	: $self->has_keys('login') ? _assert_login($self)
	: Bivio::Die->die('missing form fields');
    return _su_logout($self)
	if !$realm && $req->is_substitute_user;
    _set_user($self, $realm, $req->unsafe_get('cookie'), $req);
    _set_cookie_user($self, $realm, $req);
    return 0;
}

=for html <a name="handle_cookie_in"></a>

=head2 static handle_cookie_in(Bivio::Agent::HTTP::Cookie cookie, Bivio::Agent::Request req)

Sets the I<auth_user_id> if user is logged in.   Sets the user
in the log (via I<r> record).

Doesn't read the database to validate ids, simply translates values
from cookie to real code.

=cut

sub handle_cookie_in {
    my($proto, $cookie, $req) = @_;
    _set_user($proto, _load_cookie_user($proto, $cookie, $req),
	$cookie, $req);
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->merge_initialize_info(
        shift->SUPER::internal_initialize(@_), {
	# Form versions are checked and mismatches causes VERSION_MISMATCH
	version => 1,

	# This form's "next" is the task which redirected to this form.
	# If redirect was not from a task, returns to normal "next".
	require_context => 1,

	# Fields which are shown to the user.
	visible => [
	    {
		name => 'login',
		type => 'Line',
		constraint => 'NOT_NULL',
                form_name => 'x1',
	    },
            {
                name => 'RealmOwner.password',
                form_name => 'x2',
            },
	],

	# Fields used internally which are computed dynamically.
	# They are not sent to or returned from the user.
	other => [
	    # The following fields are computed by validate
	    {
		name => 'realm_owner',
		# PropertyModels may act as types.
		type => 'Bivio::Biz::Model::RealmOwner',
		constraint => 'NONE',
	    },
	    {
		# Only set by validate
		name => 'validate_called',
		type => 'Boolean',
		constraint => 'NONE',
	    },
            {
                # Don't assert the cookie is valid
                name => 'disable_assert_cookie',
		type => 'Boolean',
		constraint => 'NONE',
            },
	],
    });

    foreach my $field (@{$info->{visible}}) {
        $field = {
            name => $field,
        } unless ref($field);
        next if $field->{form_name};
        $field->{form_name} = $field->{name};
    }
    return $info;
}

=for html <a name="substitute_user"></a>

=head2 static substitute_user(Bivio::Biz::Model realm, Bivio::Agent::Request req) : Bivio::Agent::TaskId

Become another user if you are super_user.  Returns the task to switch
to or undef (default).

=cut

sub substitute_user {
    my($proto, $realm, $req) = @_;
    # A small sanity check, since this is an important function
    $proto->assert_can_substitute_user($realm, $req);
    unless ($req->unsafe_get('super_user_id')) {
	# Only set super_user_id field if not already set.  This keeps
	# original user and doesn't allow someone to su to an admin and
	# then su as that admin.
	my($super_user_id) = $req->get('auth_user')->get('realm_id');
	my($cookie) = $req->unsafe_get('cookie');
	$cookie->put(_super_user_field($proto) => $super_user_id)
	    if $cookie;
	$req->put_durable(super_user_id => $super_user_id);
    }
    _trace($req->unsafe_get('super_user_id'), ' => ', $realm)
	if $_TRACE;
    return $proto->execute($req, {realm_owner => $realm});
}

=for html <a name="unsafe_get_cookie_user_id"></a>

=head2 static unsafe_get_cookie_user_id(Bivio::Agent::Request req) : string

Returns user_id in cookie independent of login state.

=cut

sub unsafe_get_cookie_user_id {
    my($proto, $req) = @_;
    return _get($req->unsafe_get('cookie'), $proto->USER_FIELD);
}

=for html <a name="validate"></a>

=head2 validate()

=head2 validate(string login, string password)

Checks the form property values.  Puts errors on the fields
if there are any.

=cut

sub validate {
    my($self, $login, $password) = @_;
    if (@_ == 3) {
	$self->internal_put_field(login => $login);
	$self->internal_put_field('RealmOwner.password' => $password);
    }
    return if $self->in_error;

    my($owner) = $self->validate_login;
    return unless $owner;

    unless (Bivio::Type::Password->is_equal(
	$owner->get('password'),
	$self->get('RealmOwner.password'),
    )) {
	$self->internal_put_error('RealmOwner.password', 'PASSWORD_MISMATCH');
	return;
    }
    $self->internal_put_field(realm_owner => $owner);
    $self->internal_put_field(validate_called => 1);
    return;
}

=for html <a name="validate_login"></a>

=head2 validate_login() : Bivio::Biz::Model

=head2 validate_login(string login) : Bivio::Biz::Model

=head2 static validate_login(Bivio::Biz::FormModel model) : Bivio::Biz::Model

Looks at I<login> field of I<model> and loads.
Returns a RealmOwner model, if valid.  If I<model> is not passed, uses
I<self>.

=cut

sub validate_login {
    my($self, $model_or_login) = @_;
    if (@_ >= 2) {
	if (ref($model_or_login)) {
	    $self = $model_or_login;
	}
	else {
	    $self->internal_put_field(login => $model_or_login);
	}
    }
    $self->internal_put_field(validate_called => 1);
    my($login) = $self->get('login');
    return undef
	unless defined($login);
    my($owner) = $self->new_other('RealmOwner');
    my($error) = $owner->validate_login($self->get('login'));
    $self->internal_put_error(login => $error)
	if $error;

    return $owner
	unless $error;
    return undef;
}

#=PRIVATE METHODS

# _assert_login(self) : Model.RealmOwner
#
# Asserts the login and returns the new realm_owner.
#
sub _assert_login {
    my($self) = @_;
    my($realm) = $self->validate_login;
    $self->throw_die('NOT_FOUND', {
	entity => $self->get('login'),
    }) if $self->in_error;
    return undef
	unless $realm;
    $self->throw_die('NOT_FOUND', {entity => $realm,
	message => "user's password is invalidated"})
	unless $realm->has_valid_password;
    return $realm;
}

# _assert_realm(self)
#
# Validates realm_owner is valid
#
sub _assert_realm {
    my($self) = @_;
    return undef
	unless my $realm = $self->get('realm_owner');
    my($err) = $realm->is_offline_user ? "can't login as offline user"
	: $realm->get('realm_type') != Bivio::Auth::RealmType->USER
	? "can't login as non-user"
	: $realm->is_default ? "can't login as *the* USER realm"
	: !$realm->has_valid_password ? "user's password is invalidated"
	: '';
    $self->throw_die('NOT_FOUND', {entity => $realm, message => $err})
	if $err;
    $self->internal_put_field(validate_called => 1);
    return $realm;
}

# _get(Bivio::Agent::HTTP::Cookie cookie, string field) : string
#
# Returns cookie field, if there is a cookie.
#
sub _get {
    my($cookie, $field) = @_;
    return $cookie && $cookie->unsafe_get($field);
}

# _load_cookie_user(proto, Bivio::Agent::HTTP::Cookie cookie, Bivio::Agent::Request req) : Model.RealmOwner
#
# Returns auth_user if logged in.  Otherwise indicates logged out or
# just visitor.
#
sub _load_cookie_user {
    my($proto, $cookie, $req) = @_;
    return undef unless $cookie->unsafe_get($proto->USER_FIELD);
    my($auth_user) = Bivio::Biz::Model->new($req, 'RealmOwner');
    if ($auth_user->unauth_load({
	realm_id => $cookie->get($proto->USER_FIELD),
	realm_type => Bivio::Auth::RealmType->USER,
    })) {
	return $auth_user
	    if $req->is_substitute_user;

	# Must have password to be logged in
	my($cp) = _get($cookie, $proto->PASSWORD_FIELD);
	return undef
	    unless $cp;
	return $auth_user
	    if $auth_user->has_valid_password
		&& $cp eq $auth_user->get('password');
	$req->warn($auth_user, ': user is not valid');
    }
    else {
	$req->warn($cookie->get($proto->USER_FIELD),
	    ': user_id not found, logging out');
    }
    $cookie->delete($proto->USER_FIELD, $proto->PASSWORD_FIELD);
    # If user is invalid, logout as super user
    _su_logout($proto->new($req))
	if $req->is_substitute_user;
    return undef;
}

# _set_cookie_user(Bivio::Biz::FormModel self, Bivio::Biz::Model::RealmOwner realm, Bivio::Agent::Request req)
#
# Checks to see if the cookie was received.  If so, set the state.
#
sub _set_cookie_user {
    my($self, $realm, $req) = @_;

    # If there's no cookie, just ignore (probably command line app)
    my($cookie) = $req->unsafe_get('cookie');
    return unless $cookie;

    # If logging in, need to have a cookie.
    Bivio::Agent::HTTP::Cookie->assert_is_ok($req)
	if $realm && ! $self->unsafe_get('disable_assert_cookie');
    if ($realm) {
	$cookie->put(
	    $self->USER_FIELD => $realm->get('realm_id'),
	    $self->PASSWORD_FIELD => $realm->get('password'),
	);
    }
    else {
	$cookie->delete($self->PASSWORD_FIELD);
    }
    return;
}

# _set_log_user(proto, Bivio::Agent::HTTP::Cookie cookie, Bivio::Agent::Request req)
#
# Set the user for this connection.  Shows up in the server log.
#
sub _set_log_user {
    my($proto, $cookie, $req) = @_;
    my($r) = $req->unsafe_get('r');
    return unless $r && _get($cookie, $proto->USER_FIELD);
    my($super_user_id) = _get(
	$cookie,
	_super_user_field($proto),
    );
    $r->connection->user(
	($super_user_id ? 'su-' . $super_user_id . '-' : '')
	. ($req->get('user_state') == Bivio::Type::UserState->LOGGED_IN
	    ? 'li-' : 'lo-')
        . _get($cookie, $proto->USER_FIELD));
    return;
}

# _set_user(proto, Bivio::Biz::Model user, Bivio::Agent::HTTP::Cookie cookie, Bivio::Agent::Request req)
#
# Sets user on request based on cookie state.
#
sub _set_user {
    my($proto, $user, $cookie, $req) = @_;
    $req->set_user($user);
    $req->put_durable(
	# Cookie overrides but may not have a cookie so super_user_id
	super_user_id => _get($cookie, _super_user_field($proto))
	    || $req->unsafe_get('super_user_id'),
	user_state => $user ? Bivio::Type::UserState->LOGGED_IN
	    : _get($cookie, $proto->USER_FIELD)
	    ? Bivio::Type::UserState->LOGGED_OUT
	    : Bivio::Type::UserState->JUST_VISITOR,
    );
    _set_log_user($proto, $cookie, $req);
    return $user;
}

# _su_logout(self) : Bivio::Agent::TaskId
#
# Logout as substitute user, return to super user.
#
sub _su_logout {
    return Bivio::Biz::Model->get_instance('AdmSubstituteUserForm')
        ->su_logout(shift->get_request());
}

# _super_user_field(proto) : string
#
# Returns SUPER_USER_FIELD
#
sub _super_user_field {
    return shift->get_instance('AdmSubstituteUserForm')->SUPER_USER_FIELD;
}

=head1 COPYRIGHT

Copyright (c) 1999-2002 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
