# Copyright (c) 2011-2023 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserLoginBaseForm;
use strict;
use Bivio::Base 'Biz.FormModel';


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

sub _validate {
    my($self) = @_;
    my($owner) = $self->validate_login;
    return
        if !$owner || ($self->in_error && !$owner->require_otp);
    my($pw_input) = $self->get('RealmOwner.password');
    unless ($owner->get_field_type('password')->is_equal($owner->get('password'), $pw_input)) {
        return $self->internal_put_error(
            'RealmOwner.password', 'PASSWORD_MISMATCH',
        ) unless $owner->require_otp;
        return $self->internal_put_error(
            'RealmOwner.password' => 'OTP_PASSWORD_MISMATCH'
        ) unless $self->new_other('OTP')->unauth_load_or_die({
            user_id => $owner->get('realm_id')
        })->verify($pw_input);
    }
    $owner->maybe_upgrade_password($pw_input);
    $self->internal_put_field(validate_called => 1);
    return;
}

1;
