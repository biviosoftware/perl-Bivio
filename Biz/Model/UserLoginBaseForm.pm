# Copyright (c) 2011-2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserLoginBaseForm;
use strict;
use Bivio::Base 'Biz.FormModel';
b_use('IO.Trace');

our($_TRACE);
my($_A) = b_use('Action.Acknowledgement');
my($_AAC) = b_use('Action.AccessChallenge');
my($_DT) = b_use('Type.DateTime');
my($_LAS) = b_use('Type.LoginAttemptState');
my($_MM) = b_use('Type.MFAMethod');
my($_R) = b_use('Biz.Random');
my($_TAC) = b_use('Type.AccessCode');
my($_TACS) = b_use('Type.AccessCodeStatus');

sub PASSWORD_FIELD {
    return 'p';
}

sub USER_FIELD {
    return 'u';
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
    my(undef, $delegator, $cookie, $req) = shift->delegated_args(@_);
    my($cookie_user) = $delegator->load_cookie_user($req, $cookie);
    if ($cookie_user) {
        my($need_mfa_cookie);
        my($have_mfa_cookie);
        foreach my $m (@{$cookie_user->get_configured_mfa_methods || []}) {
            $need_mfa_cookie = 1;
            next
                unless $m->{type}->get_login_form_class->is_valid_cookie($cookie, $cookie_user);
            $have_mfa_cookie = 1;
            last;
        }
        $cookie_user = undef
            if $need_mfa_cookie && !$have_mfa_cookie;
    }
    $delegator->set_user($cookie_user, $cookie, $req);
    return;
}

sub internal_challenge_redirect {
    my(undef, $delegator, $realm, $res, $req) = shift->delegated_args(@_);
    return
        unless $req->ureq('cookie');
    return
        unless ($realm && !$realm->require_otp && $delegator->unsafe_get('validate_called'))
        || $delegator->unsafe_get('require_mfa');
    _trace('successful login; creating challenge for user=', $realm)
        if $_TRACE;
    # No precursor that creates challenge, so creating passed challenge here.
    $_AAC->create_challenge($req, $realm, $_TAC->LOGIN_CHALLENGE)
        ->update({status => $_TACS->PASSED});
    return $_AAC->do_plain_or_mfa($realm, sub {
        _trace('no MFA; setting user, escalation code, redirecting to next task')
            if $_TRACE;
        $delegator->set_user($realm, $req->ureq('cookie'), $req);
        # Initial login treated as an escalation so user doesn't have to present credentials
        # twice within a short period.
        $_AAC->create_challenge($req, $realm, $_TAC->ESCALATION_CHALLENGE)
            ->update({status => $_TACS->PASSED});
        return $_AAC->get_next($req) || $res;
    }, undef, 1);
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
                type => 'LoginName',
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
            {
                name => 'require_mfa',
                type => 'Boolean',
                constraint => 'NONE',
            },
            {
                name => 'no_record',
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

sub internal_invalidate_cookie_user {
    my($proto, $cookie) = @_;
    $cookie->delete(
        $proto->USER_FIELD,
        $proto->PASSWORD_FIELD,
    );
    return;
}

sub internal_validate_cookie_user {
    my($proto, $req, $cookie, $auth_user) = @_;
    # Must have password to be logged in
    my($cp) = $cookie && $cookie->unsafe_get($proto->PASSWORD_FIELD);
    return 0
        unless $cp;
    return 1
        if _validate_cookie_password($cp, $auth_user);
    return 0;
}

sub internal_validate_login_value {
    my(undef, $delegator, $value) = shift->delegated_args(@_);
    my($owner) = $delegator->new_other('RealmOwner');
    my($err) = $owner->validate_login($value);
    return $err ? (undef, $err) : ($owner, undef);
}

sub load_cookie_user {
    my(undef, $delegator, $req, $cookie) = shift->delegated_args(@_);
    # Returns auth_user if logged in.  Otherwise indicates logged out or
    # just visitor.
    return undef
        unless $cookie->unsafe_get($delegator->USER_FIELD);
    my($auth_user) = Bivio::Biz::Model->new($req, 'RealmOwner');
    if ($auth_user->unauth_load({
        realm_id => $cookie->get($delegator->USER_FIELD),
        realm_type => Bivio::Auth::RealmType->USER,
    })) {
        return $delegator->internal_validate_cookie_user($req, $cookie, $auth_user)
            ? $auth_user : undef;
        $req->warn($auth_user, ': user is not valid');
    }
    else {
        $req->warn($cookie->get($delegator->USER_FIELD),
            ': user_id not found, logging out');
    }
    $delegator->internal_invalidate_cookie_user($cookie);
    foreach my $t ($_MM->get_non_zero_list) {
        $t->get_login_form_class->delete_cookie($cookie);
    }
    return undef;
}

sub record_login_attempt {
    my(undef, undef, $owner, $success) = shift->delegated_args(@_);
    return _maybe_lock_out($owner, $owner->new_other('LoginAttempt')->create({
        realm_id => $owner->get('realm_id'),
        login_attempt_state => $success ? $_LAS->SUCCESS : $_LAS->FAILURE,
    }));
}

sub set_user {
    my(undef, $delegator, $user, $cookie, $req) = shift->delegated_args(@_);
    # Sets user on request based on cookie state.
    $req->set_user($user);
    $req->put_durable(
        # Cookie overrides but may not have a cookie so super_user_id
        super_user_id => _get($cookie, _super_user_field($delegator))
            || $req->unsafe_get('super_user_id'),
        user_state => $delegator->use('Type.UserState')->from_name(
            $user ? 'LOGGED_IN'
            : _get($cookie, $delegator->USER_FIELD)
            ? 'LOGGED_OUT' : 'JUST_VISITOR'),
    );
    _set_log_user($delegator, $cookie, $req);
    return $user;
}

sub validate {
    my(undef, $delegator, $login, $password, $no_record) = shift->delegated_args(@_);
    $delegator->internal_put_field(validate_called => 1);
    if (defined($login) && defined($password)) {
        $delegator->internal_put_field(
            login => $login,
            'RealmOwner.password' => $password,
            no_record => $no_record,
        );
    }
    _validate($delegator);
    # don't send password back to client in error case
    if ($delegator->in_error) {
        $delegator->internal_put_field('RealmOwner.password' => undef);
        $delegator->internal_clear_literal('RealmOwner.password');
    }
    return;
}

sub validate_login {
    my(undef, $delegator, $model_or_login, $field) = shift->delegated_args(@_);
    $field ||= 'login';
    my($model) = ref($model_or_login) ? $model_or_login : $delegator;
    $model->internal_put_field($field => $model_or_login)
        if defined($model_or_login) && !ref($model_or_login);
    my($login) = $model->get($field);
    return undef
        unless defined($login);
    my($realm, $err) = $delegator->internal_validate_login_value($login);
    $model->internal_put_error($field => $err)
        if $err;
    $model->internal_put_field(realm_owner => $realm);
    return $realm;
}

sub _get {
    my($cookie, $field) = @_;
    # Returns cookie field, if there is a cookie.
    return $cookie && $cookie->unsafe_get($field);
}

sub _maybe_lock_out {
    my($owner, $attempt) = @_;
    if ($attempt->is_state_locked_out) {
        b_warn('locked out owner=', $owner);
        $owner->update_password($_R->password);
        $owner->req->set_user(undef);
        $owner->req->server_redirect('GENERAL_USER_LOCKED_OUT');
        # DOES NOT RETURN
    }
    return $attempt;
}

sub _password_error {
    my($self, $owner) = @_;
    my($pw_err);
    return undef
        if $owner->get_field_type('password')->is_equal(
            $owner->get('password'),
            $self->get('RealmOwner.password'),
        );
    return 'PASSWORD_MISMATCH'
        unless $owner->require_otp;
    return 'OTP_PASSWORD_MISMATCH'
        unless $self->new_other('OTP')->unauth_load_or_die({
            user_id => $owner->get('realm_id')
        })->verify($self->get('RealmOwner.password'));
    return undef;
}

sub _set_log_user {
    my($proto, $cookie, $req, $override_user_id) = @_;
    # Set the user for this connection.  Shows up in the server log.
    my($r) = $req->unsafe_get('r');
    return unless $r;
    my($uid) = $req->get('auth_user_id')
        || _get($cookie, $proto->USER_FIELD);
    my($suid) = $req->unsafe_get('super_user_id')
        || _get($cookie, _super_user_field($proto));
    $r->connection->user(
        ($suid ? 'su-' . $suid . '-' : '')
        . ($uid ? ($req->get('user_state')->eq_logged_in ? 'li-' : 'lo-') . $uid
        : ''));
    return;
}

sub _super_user_field {
    return shift->get_instance('AdmSubstituteUserForm')->SUPER_USER_FIELD;
}

sub _validate {
    my($self) = @_;
    my($owner) = $self->validate_login;
    return
        if !$owner || ($self->in_error && !$owner->require_otp);
    return $self->internal_put_error(login => 'USER_LOCKED_OUT')
        if $owner->is_locked_out;
    _validate_login_attempt($self, $owner);
    return
        if $self->in_error && !$owner->require_otp;
    $owner->maybe_upgrade_password($self->get('RealmOwner.password'))
        if $self->get('RealmOwner.password');
    $self->record_login_attempt($owner, 1)
        unless $self->unsafe_get('no_record');
    return;
}

sub _validate_cookie_password {
    my($passwd, $auth_user) = @_;
    return $auth_user->require_otp
        ? $auth_user->new_other('OTP')->validate_password($passwd, $auth_user)
        : $passwd eq $auth_user->get('password') ? 1 : 0;
}

sub _validate_login_attempt {
    my($self, $owner) = @_;
    if (my $err = _password_error($self, $owner)) {
        # Need to stay on page or the login attempt would get rolled back
        $self->internal_stay_on_page;
        $self->internal_put_error('RealmOwner.password' => $err);
        $self->record_login_attempt($owner, 0)
            unless $self->unsafe_get('no_record');
    }
    return;
}

1;
