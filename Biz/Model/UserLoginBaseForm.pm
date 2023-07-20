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
                name => 'do_lockout_mail_task',
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
    my($self, $value) = @_;
    my($owner) = $self->new_other('RealmOwner');
    my($err) = $owner->validate_login($value);
    return $err ? (undef, $err) : ($owner, undef);
}

sub validate {
    my($self, $login, $password) = @_;
    # Checks the form property values.  Puts errors on the fields
    # if there are any.
    if (@_ == 3) {
        $self->internal_put_field(login => $login);
        $self->internal_put_field('RealmOwner.password' => $password);
    }
    _validate($self);
    # don't send password back to client in error case
    if ($self->in_error) {
        $self->internal_put_field('RealmOwner.password' => undef);
        $self->internal_clear_literal('RealmOwner.password');
    }
    return;
}

sub validate_and_execute_ok {
    my($self) = @_;
    my($res) = shift->SUPER::validate_and_execute_ok(@_);
    if ($self->unsafe_get('do_lockout_mail_task')) {
        $self->put_on_request(1);
        return {
            method => 'server_redirect',
            task_id => 'lockout_mail_task',
            query => undef,
        };
    }
    return $res;
}

sub validate_login {
    my($self, $model_or_login, $field) = @_;
    $field ||= 'login';
    my($model) = ref($model_or_login) ? $model_or_login : $self;
    $model->internal_put_field($field => $model_or_login)
        if defined($model_or_login) && !ref($model_or_login);
    $model->internal_put_field(validate_called => 1);
    my($login) = $model->get($field);
    return undef
        unless defined($login);
    my($realm, $err) = $self->internal_validate_login_value($login);
    $model->internal_put_error($field => $err)
        if $err;
    $model->internal_put_field(realm_owner => $realm);
    return $realm;
}

sub _password_error {
    my($self, $owner) = @_;
    my($pw_err);
    unless ($owner->get_field_type('password')->is_equal(
        $owner->get('password'),
        $self->get('RealmOwner.password'),
    )) {
        return 'PASSWORD_MISMATCH'
            unless $owner->require_otp;
        return 'OTP_PASSWORD_MISMATCH'
            unless $self->new_other('OTP')->unauth_load_or_die({
                user_id => $owner->get('realm_id')
            })->verify($self->get('RealmOwner.password'));
    }
    return;
}

sub _record_login_attempt {
    my($self, $owner, $success) = @_;
    return $self->req->with_realm($owner, sub {
        return $self->new_other('LoginAttempt')->create({
            login_attempt_state => $success ? $_LAS->SUCCESS : $_LAS->FAILURE,
        });
    });
}

sub _validate {
    my($self) = @_;
    my($owner) = $self->validate_login;
    return
        if !$owner || ($self->in_error && !$owner->require_otp);
    return
        unless _validate_login_attempt($self, $owner);
    $self->internal_put_field(validate_called => 1);
    return;
}

sub _validate_login_attempt {
    my($self, $owner) = @_;
    if (my $err = _password_error($self, $owner)) {
        # Need to stay on page or the login attempt would get rolled back
        $self->internal_stay_on_page;
        $self->internal_put_error('RealmOwner.password' => $err);
        if (_record_login_attempt($self, $owner, 0)->get('login_attempt_state')->eq_lockout) {
            b_warn('lockout owner=', $owner);
            $owner->update_password($_R->password);
            $self->internal_put_field(do_lockout_mail_task => 1);
        }
        return 0;
    }
    _record_login_attempt($self, $owner, 1);
    return 1;
}

1;
