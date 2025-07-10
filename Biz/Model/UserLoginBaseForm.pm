# Copyright (c) 2011-2023 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserLoginBaseForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_LAS) = b_use('Type.LoginAttemptState');
my($_R) = b_use('Biz.Random');

sub PASSWORD_FIELD {
    return 'p';
}

sub USER_FIELD {
    # Returns the cookie key for the super user value.
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
            {
                name => 'totp_code',
                type => 'Line',
                constraint => 'NONE',
            },
        ],
        hidden => [
            {
                name => 'do_totp',
                type => 'Boolean',
                constraint => 'NONE',
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
                name => 'do_locked_out_task',
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

sub internal_validate_login_value {
    my(undef, $delegator, $value) = shift->delegated_args(@_);
    my($owner) = $delegator->new_other('RealmOwner');
    my($err) = $owner->validate_login($value);
    return $err ? (undef, $err) : ($owner, undef);
}

sub validate {
    my(undef, $delegator, $login, $password) = shift->delegated_args(@_);
    # Checks the form property values.  Puts errors on the fields
    # if there are any.
    if (defined($login) && defined($password)) {
        $delegator->internal_put_field(login => $login);
        $delegator->internal_put_field('RealmOwner.password' => $password);
    }
    _validate($delegator);
    # don't send password back to client in error case
    if ($delegator->in_error) {
        $delegator->internal_put_field('RealmOwner.password' => undef);
        $delegator->internal_clear_literal('RealmOwner.password');
    }
    return;
}

sub validate_and_execute_ok {
    my(undef, $delegator) = shift->delegated_args(@_);
    my($res) = $delegator->SUPER::validate_and_execute_ok(@_);
    if ($delegator->unsafe_get('do_locked_out_task')) {
        $delegator->put_on_request(1);
        return {
            method => 'server_redirect',
            task_id => 'locked_out_task',
            query => undef,
        };
    }
    return $res;
}

sub validate_login {
    my(undef, $delegator, $model_or_login, $field) = shift->delegated_args(@_);
    $field ||= 'login';
    my($model) = ref($model_or_login) ? $model_or_login : $delegator;
    $model->internal_put_field($field => $model_or_login)
        if defined($model_or_login) && !ref($model_or_login);
    $model->internal_put_field(validate_called => 1);
    my($login) = $model->get($field);
    return undef
        unless defined($login);
    my($realm, $err) = $delegator->internal_validate_login_value($login);
    $model->internal_put_error($field => $err)
        if $err;
    $model->internal_put_field(realm_owner => $realm);
    return $realm;
}

sub _maybe_lock_out {
    my($self, $owner) = @_;
    if (_record_login_attempt($self, $owner, 0)->get('login_attempt_state')->eq_locked_out) {
        b_warn('locked out owner=', $owner);
        $owner->update_password($_R->password);
        $self->internal_put_field(do_locked_out_task => 1);
    }
    return;
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

sub _record_login_attempt {
    my($self, $owner, $success) = @_;
    return $self->new_other('LoginAttempt')->create({
        realm_id => $owner->get('realm_id'),
        login_attempt_state => $success ? $_LAS->SUCCESS : $_LAS->FAILURE,
    });
}

sub _validate_totp {
    my($self, $owner) = @_;
    my($totp) = $self->new_other('TOTP');
    return 1
        unless $totp->unauth_load({user_id => $owner->get('realm_id')});
    if ($self->get('do_totp') && (my $totp_code = $self->get('totp_code'))) {
        return 1
            if $totp->validate_input_code($totp_code);
        # Need to stay on page or the login attempt would get rolled back
        $self->internal_stay_on_page;
        $self->internal_put_error(totp_code => 'INVALID_TOTP_CODE');
        _maybe_lock_out($self, $owner);
        return 0;
    }
    elsif ($self->get('do_totp')) {
        $self->internal_put_error(totp_code => 'NULL');
        return 0;
    }
    $self->internal_stay_on_page;
    $self->internal_put_field(do_totp => 1);
    return 0;
}

sub _validate {
    my($self) = @_;
    my($owner) = $self->validate_login;
    return
        if !$owner || ($self->in_error && !$owner->require_otp);
    return $self->internal_put_error(login => 'USER_LOCKED_OUT')
        if $owner->is_locked_out;
    return
        unless _validate_login_attempt($self, $owner);
    $owner->maybe_upgrade_password($self->get('RealmOwner.password'));
    return
        unless _validate_totp($self, $owner);
    _record_login_attempt($self, $owner, 1);
    # isn't this already done in validate_login?
    $self->internal_put_field(validate_called => 1);
    return;
}

sub _validate_login_attempt {
    my($self, $owner) = @_;
    if (my $err = _password_error($self, $owner)) {
        # Need to stay on page or the login attempt would get rolled back
        $self->internal_stay_on_page;
        $self->internal_put_error('RealmOwner.password' => $err);
        _maybe_lock_out($self, $owner);
        return 0;
    }
    return 1;
}

1;
