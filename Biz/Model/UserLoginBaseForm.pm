# Copyright (c) 2011-2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserLoginBaseForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_A) = b_use('Action.Acknowledgement');
my($_DT) = b_use('Type.DateTime');
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

sub execute_ok {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_ok(@_);
    return @res
        if $self->in_error;
    # TODO: use require_totp or override_require_totp?
    return @res
        unless ($self->unsafe_get('realm_owner') && $self->unsafe_get('validate_called'))
        || $self->unsafe_get('require_totp');
    return $self->get('realm_owner')->require_totp ? {
        method => 'server_redirect',
        task_id => 'totp_task',
        # TODO: need this?
        # no_context => 1,
    } : @res;
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
        hidden => [
            {
                name => 'password_query_code',
                type => 'Line',
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
            {
                name => 'password_query_code_model',
                type => 'Model.UserRecoveryCode',
                constraint => 'NONE',
            },
            {
                name => 'require_totp',
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

sub record_login_attempt {
    my(undef, $owner, $success) = @_;
    return _maybe_lock_out($owner, $owner->new_other('LoginAttempt')->create({
        realm_id => $owner->get('realm_id'),
        login_attempt_state => $success ? $_LAS->SUCCESS : $_LAS->FAILURE,
    }));
}

sub validate {
    my(undef, $delegator, $login, $password) = shift->delegated_args(@_);
    my($form_button);
    if (defined($login) && defined($password)) {
        $delegator->internal_put_field(login => $login);
        $delegator->internal_put_field('RealmOwner.password' => $password);
    }
    elsif (defined($login)) {
        $form_button = $login;
    }
    _validate($delegator, $form_button);
    # don't send secrets back to client in error case
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
    my($owner, $attempt) = @_;
    if ($attempt->is_state_locked_out) {
        b_warn('locked out owner=', $owner);
        $owner->update_password($_R->password);
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

sub _validate {
    my($self, $form_button) = @_;
    my($owner) = $self->validate_login;
    return
        unless $owner;
    return $self->internal_put_error(login => 'USER_LOCKED_OUT')
        if $owner->is_locked_out;
    _validate_login_attempt($self, $owner);
    return
        if $self->in_error && !$owner->require_otp;
    $owner->maybe_upgrade_password($self->get('RealmOwner.password'))
        if $self->get('RealmOwner.password');
    $self->record_login_attempt($owner, 1);
    return;
}

sub _validate_login_attempt {
    my($self, $owner) = @_;
    return
        if $self->unsafe_get('password_query_code_model');
    return
        unless $self->get('RealmOwner.password');
    if (my $err = _password_error($self, $owner)) {
        # Need to stay on page or the login attempt would get rolled back
        $self->internal_stay_on_page;
        $self->internal_put_error('RealmOwner.password' => $err);
        $self->internal_put_field(do_locked_out_task => 1)
            if $self->record_login_attempt($owner, 0)->is_state_locked_out;
    }
    return;
}

1;
