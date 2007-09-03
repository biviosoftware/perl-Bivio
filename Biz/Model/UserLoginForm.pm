# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::UserLoginForm;
use strict;
use Bivio::Base 'Bivio::Biz::FormModel';
use Bivio::IO::Trace;

# C<Bivio::Biz::Model::UserLoginForm> is used to login which changes the
# cookie.  Modules which "login" users should call <tt>execute</tt>
# with the new realm_owner.
#
# A user is logged in if his PASSWORD_FIELD is set in the cookie.  We keep the
# user_id in the cookie so we can track logged out users.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
__PACKAGE__->use('Bivio::Agent::HTTP::Cookie')->register(__PACKAGE__);

sub PASSWORD_FIELD {
    return 'p';
}

sub SUPER_USER_FIELD {
    # B<DEPRECATED>:
    # L<Bivio::Biz::Model::AdmSubstituteUserForm::SUPER_USER_FIELD|Bivio::Biz::Model::AdmSubstituteUserForm/SUPER_USER_FIELD>
    Bivio::IO::Alert->warn_deprecated(
	q{use Bivio::Biz::Model->get_instance('AdmSubstituteUserForm')->SUPER_USER_FIELD});
    return shift->get_instance('AdmSubstituteUserForm')->SUPER_USER_FIELD;
}

sub USER_FIELD {
    # Returns the cookie key for the super user value.
    return 'u';
}

sub assert_can_substitute_user {
    my($proto, $new_user, $req) = @_;
    # Dies unless user is super user.  Subclasses can override this method
    # to relax this constraint.
    Bivio::Die->throw(FORBIDDEN => {
	message => 'not a super user',
	entity => $req->get('auth_user'),
	request => $req,
    }) unless $req->is_super_user;
    return;
}

sub disable_assert_cookie {
    shift->internal_put_field(disable_assert_cookie => 1);
    return;
}

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
    _set_cookie_user($self, $req, $realm);
    return 0
	unless $realm && $realm->require_otp;
    return 0
	unless $self->new_other('OTP')->unauth_load_or_die({
	    user_id => $realm->get('realm_id'),
	})->should_reinit;
    return {
        task_id => 'USER_OTP',
	query => undef,
    };
}

sub get_basic_authorization_realm {
    my($self) = shift;
    my($ro) = $self->unsafe_get('realm_owner');
    return $ro && $ro->require_otp
	# Extra space helps out on Mac, which puts a '.' right after realm
	? 'Challenge: ' . $self->req('Model.OTP')->get_challenge . ' '
	: '*';
}

sub handle_cookie_in {
    # Sets the I<auth_user_id> if user is logged in.   Sets the user
    # in the log (via I<r> record).
    #
    # Doesn't read the database to validate ids, simply translates values
    # from cookie to real code.
    my($proto, $cookie, $req) = @_;
    $proto = Bivio::Biz::Model->get_instance('UserLoginForm');
    _set_user($proto, _load_cookie_user($proto, $cookie, $req),
	$cookie, $req);
    return;
}

sub internal_initialize {
    my($self) = @_;
    # B<FOR INTERNAL USE ONLY>
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
	    {
		name => 'via_mta',
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

sub substitute_user {
    my($proto, $new_user, $req) = @_;
    my($self) = ref($proto) ? $proto : $proto->new($req);
    # Become another user if you are super_user.  Returns the task to switch
    # to or undef (default).
    # A small sanity check, since this is an important function
    $self->assert_can_substitute_user($new_user, $req);
    unless ($req->unsafe_get('super_user_id')) {
	# Only set super_user_id field if not already set.  This keeps
	# original user and doesn't allow someone to su to an admin and
	# then su as that admin.
	my($super_user_id) = $req->get('auth_user')->get('realm_id');
	my($cookie) = $req->unsafe_get('cookie');
	$cookie->put(_super_user_field($self) => $super_user_id)
	    if $cookie;
	$req->put_durable(super_user_id => $super_user_id);
    }
    _trace($req->unsafe_get('super_user_id'), ' => ', $new_user)
	if $_TRACE;
    return $self->process({
	realm_owner => $new_user,
	disable_assert_cookie => $self->unsafe_get('disable_assert_cookie') || 0,
    });
}

sub unsafe_get_cookie_user_id {
    my($proto, $req) = @_;
    # Returns user_id in cookie independent of login state.
    return _get($req->unsafe_get('cookie'), $proto->USER_FIELD);
}

sub validate {
    my($self, $login, $password) = @_;
    # Checks the form property values.  Puts errors on the fields
    # if there are any.
    if (@_ == 3) {
	$self->internal_put_field(login => $login);
	$self->internal_put_field('RealmOwner.password' => $password);
    }
    my($owner) = $self->validate_login;
    return
	if !$owner || ($self->in_error && !$owner->require_otp);
    unless ($owner->get_field_type('password')->is_equal(
	$owner->get('password'),
	$self->get('RealmOwner.password'),
    )) {
	return $self->internal_put_error(
	    'RealmOwner.password', 'PASSWORD_MISMATCH',
	) unless $owner->require_otp;
	return $self->internal_put_error(
	    'RealmOwner.password' => 'OTP_PASSWORD_MISMATCH'
	) unless $self->new_other('OTP')->unauth_load_or_die({
	    user_id => $owner->get('realm_id')
	})->verify($self->get('RealmOwner.password'));
    }
    $self->internal_put_field(validate_called => 1);
    return;
}

sub validate_login {
    my($self, $model_or_login) = @_;
    # Looks at I<login> field of I<model> and loads.
    # If valid, puts RealmOwner in I<realm_owner> and returns it.
    # If I<model> is not passed, uses I<self>.
    if ($model_or_login) {
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
    if ($error) {
	$self->internal_put_error(login => $error);
	return undef;
    }

    $self->internal_put_field(realm_owner => $owner);
    return $owner;
}

sub _assert_login {
    my($self) = @_;
    # Asserts the login and returns the new realm_owner.
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

sub _assert_realm {
    my($self) = @_;
    # Validates realm_owner is valid
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

sub _cookie_password {
    my($realm) = @_;
    return $realm->require_otp
	? $realm->new_other('OTP')
	    ->unauth_load_or_die({user_id => $realm->get('realm_id')})
	    ->get('otp_md5')
	: $realm->get('password')
}

sub _get {
    my($cookie, $field) = @_;
    # Returns cookie field, if there is a cookie.
    return $cookie && $cookie->unsafe_get($field);
}

sub _load_cookie_user {
    my($proto, $cookie, $req) = @_;
    # Returns auth_user if logged in.  Otherwise indicates logged out or
    # just visitor.
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
	    if _validate_cookie_password($cp, $auth_user);
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

sub _set_cookie_user {
    my($self, $req, $realm) = @_;
    # Checks to see if the cookie was received.  If so, set the state.

    # If there's no cookie, just ignore (probably command line app)
    my($cookie) = $req->unsafe_get('cookie');
    return unless $cookie;

    # If logging in, need to have a cookie.
    Bivio::Agent::HTTP::Cookie->assert_is_ok($req)
	if $realm && ! $self->unsafe_get('disable_assert_cookie');
    if ($realm) {
	$cookie->put(
	    $self->USER_FIELD => $realm->get('realm_id'),
	    $self->PASSWORD_FIELD => _cookie_password($realm),
	);
    }
    else {
	$cookie->delete($self->PASSWORD_FIELD);
    }
    return;
}

sub _set_log_user {
    my($proto, $cookie, $req) = @_;
    # Set the user for this connection.  Shows up in the server log.
    my($r) = $req->unsafe_get('r');
    return unless $r && _get($cookie, $proto->USER_FIELD);
    my($super_user_id) = _get(
	$cookie,
	_super_user_field($proto),
    );
    $r->connection->user(
	($super_user_id ? 'su-' . $super_user_id . '-' : '')
	. ($req->get('user_state') == $proto->use('Type.UserState')->LOGGED_IN
	    ? 'li-' : 'lo-')
        . _get($cookie, $proto->USER_FIELD));
    return;
}

sub _set_user {
    my($proto, $user, $cookie, $req) = @_;
    # Sets user on request based on cookie state.
    $req->set_user($user);
    $req->put_durable(
	# Cookie overrides but may not have a cookie so super_user_id
	super_user_id => _get($cookie, _super_user_field($proto))
	    || $req->unsafe_get('super_user_id'),
	user_state => $proto->use('Type.UserState')->from_name(
	    $user ? 'LOGGED_IN'
	    : _get($cookie, $proto->USER_FIELD)
	    ? 'LOGGED_OUT' : 'JUST_VISITOR'),
    );
    _set_log_user($proto, $cookie, $req);
    return $user;
}

sub _su_logout {
    # Logout as substitute user, return to super user.
    return Bivio::Biz::Model->get_instance('AdmSubstituteUserForm')
        ->su_logout(shift->get_request());
}

sub _super_user_field {
    # Returns SUPER_USER_FIELD
    return shift->get_instance('AdmSubstituteUserForm')->SUPER_USER_FIELD;
}

sub _validate_cookie_password {
    my($passwd, $auth_user) = @_;
    return $auth_user->require_otp
	? $auth_user->new_other('OTP')->validate_password($passwd, $auth_user)
	: $passwd eq $auth_user->get('password') ? 1 : 0;
}

1;
