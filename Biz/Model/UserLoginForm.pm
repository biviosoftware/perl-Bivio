# Copyright (c) 1999-2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserLoginForm;
use strict;
use Bivio::Base 'Model.UserLoginBaseForm';
b_use('IO.Trace');

# C<Bivio::Biz::Model::UserLoginForm> is used to login which changes the
# cookie.  Modules which "login" users should call <tt>execute</tt>
# with the new realm_owner.
#
# A user is logged in if their PASSWORD_FIELD is set in the cookie.  We keep the
# user_id in the cookie so we can track logged out users.

our($_TRACE);
b_use('IO.Config')->register(my $_CFG = {
    register_with_cookie => 1,
});
(my $_C = b_use('AgentHTTP.Cookie'))->register(__PACKAGE__)
    if $_CFG->{register_with_cookie};
b_use('Agent.Task')->register(__PACKAGE__);

sub SUPER_USER_FIELD {
    # B<DEPRECATED>:
    # L<Bivio::Biz::Model::AdmSubstituteUserForm::SUPER_USER_FIELD|Bivio::Biz::Model::AdmSubstituteUserForm/SUPER_USER_FIELD>
    Bivio::IO::Alert->warn_deprecated(
        q{use Bivio::Biz::Model->get_instance('AdmSubstituteUserForm')->SUPER_USER_FIELD});
    return shift->get_instance('AdmSubstituteUserForm')->SUPER_USER_FIELD;
}

sub disable_assert_cookie {
    shift->internal_put_field(disable_assert_cookie => 1);
    return;
}

sub execute_ok {
    my($self) = @_;
    my($res) = shift->SUPER::execute_ok(@_);
    my($req) = $self->get_request;
    my($realm) = $self->unsafe_get('validate_called')
        ? $self->get('realm_owner')
        : $self->has_keys('realm_owner') ? _assert_realm($self)
        : $self->has_keys('login') ? _assert_login($self)
        : b_die('missing form fields');
    b_die('RealmOwner.password was NOT CHECKED')
        if defined($self->unsafe_get('RealmOwner.password'))
        && !$self->unsafe_get('validate_called');
    return _su_logout($self)
        if !$realm && $req->is_substitute_user;
    if ($realm && $realm->is_locked_out && !$req->is_substitute_user) {
        b_warn('locked owner=', $self);
        $self->throw_die('NOT_FOUND', {entity => $realm});
        # DOES NOT RETURN
    }
    _set_cookie_user($self, $req, $realm);
    if (defined(my $cr = $self->internal_challenge_redirect($realm, $res, $req))) {
        return $cr;
    }
    $self->set_user($realm, $req->unsafe_get('cookie'), $req);
    return $res
        unless $realm && $realm->require_otp;
    return $res
        unless $self->new_other('OTP')->unauth_load_or_die({
            user_id => $realm->get('realm_id'),
        })->should_reinit;
    return {
        task_id => 'USER_OTP',
        query => undef,
    };
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub handle_pre_auth_task {
    my($proto, $task, $req) = @_;
    # If user is invalid, logout as super user
    _su_logout($proto->new($req))
        if $req->is_substitute_user && !$req->get('auth_user');
    return 0;
}

sub substitute_user {
    my($proto, $new_user, $req, $form) = @_;
    my($self) = ref($proto) ? $proto : $proto->new($req);
    # Become another user if you are super_user.  Returns the task to switch
    # to or undef (default).
    # A small sanity check, since this is an important function
    Bivio::Die->throw(FORBIDDEN => {
        message => 'not a super user',
        entity => $req->get('auth_user'),
        request => $req,
    }) unless ($form || $self->new_other('AdmSubstituteUserForm'))
        ->can_substitute_user($new_user->get('realm_id'));
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
    foreach my $class (
        $self,
        map($_->{type}->get_login_form_class, @{$new_user->get_configured_mfa_methods || []}),
    ) {
        $class->new($req)->process({
            realm_owner => $new_user,
            $self->equals_class_name($class->as_classloader_map_name) ? (
                disable_assert_cookie => _disable_assert_cookie($self),
            ) : (
                bypass_challenge => 1,
            ),
        });
    }
    return;
}

sub unsafe_get_cookie_user_id {
    my($proto, $req) = @_;
    # Returns user_id in cookie independent of login state.
    return $req->ureq('cookie') && $req->req('cookie')->unsafe_get($proto->USER_FIELD);
}

sub _assert_login {
    my($self) = @_;
    my($realm) = $self->validate_login;
    $self->throw_die('NOT_FOUND', {
        entity => $self->get('login'),
    }) if $self->in_error;
    return $realm;
}

sub _assert_realm {
    my($self) = @_;
    # Validates realm_owner is valid
    return undef
        unless my $realm = $self->get('realm_owner');
    my($err) = $realm->validate_login_for_self;
    $self->throw_die('NOT_FOUND', {entity => $realm, message => $err})
        if $err;
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

sub _disable_assert_cookie {
    my($self) = @_;
    return $self->unsafe_get('disable_assert_cookie')
        || $self->ureq('disable_assert_cookie')
        || 0;
}

sub _set_cookie_user {
    my($self, $req, $realm) = @_;
    # Checks to see if the cookie was received.  If so, set the state.

    # If there's no cookie, just ignore (probably command line app)
    my($cookie) = $req->unsafe_get('cookie');
    return
        unless $cookie;

    # If logging in, need to have a cookie.
    $_C->assert_is_ok($req)
        if $realm && !_disable_assert_cookie($self);
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

sub _su_logout {
    return shift->new_other('AdmSubstituteUserForm')->su_logout;
}

sub _super_user_field {
    return shift->get_instance('AdmSubstituteUserForm')->SUPER_USER_FIELD;
}

1;
