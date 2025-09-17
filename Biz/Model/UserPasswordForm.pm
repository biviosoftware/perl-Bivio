# Copyright (c) 2003-2023 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserPasswordForm;
use strict;
use Bivio::Base 'Model.UserLoginTOTPForm';

my($_P) = b_use('Type.Password');
my($_SC) = b_use('Type.SecretCode');

sub PASSWORD_FIELD_LIST {
    return qw(new_password old_password confirm_new_password);
}

sub execute_ok {
    my($self) = shift;
    my($res) = $self->get('require_totp') ? $self->SUPER::execute_ok(@_) : 0;
    # Updates the password in the database and the cookie.
    $self->get_instance('UserLoginForm')->execute($self->req, {
        realm_owner => $self->get('realm_owner')
            ->update_password($self->get('new_password')),
    });
    if (my $m = $self->unsafe_get('password_query_code_model')) {
        $m->delete;
    }
    return $res;
}

sub internal_initialize {
    my($self) = @_;
    # Return config.
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
        $self->field_decl(
            visible => [
                [qw(old_password Password NONE)],
                [qw(new_password NewPassword NOT_NULL)],
                [qw(confirm_new_password ConfirmPassword NOT_NULL)],
            ],
            hidden => [
                [qw(password_query_code SecretLine NONE)],
            ],
            other => [
                [qw(require_old_password Boolean)],
                [qw(password_query_code_model Model.UserSecretCode NONE)],
                [qw(require_totp Boolean)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my($self, $method) = @_;
    # Sets the 'require_old_password' field based on if the user is the
    # super user.
    my($pqcm);
    if (
        my $pqc = $self->ureq(qw(Action.UserPasswordQuery password_query_code))
        || $self->get('password_query_code')
    ) {
        $self->internal_put_field(password_query_code => $pqc);
        $pqcm = $self->new_other('UserSecretCode')
            ->unsafe_load_by_code_and_type($pqc, $_SC->PASSWORD_RESET);
        $self->internal_put_field(password_query_code_model => $pqcm);
    }
    $self->internal_put_field(
        realm_owner => $self->req(qw(auth_realm owner)),
        require_old_password => $pqcm || $self->req->is_substitute_user ? 0 : 1,
        require_totp => $self->req(qw(auth_realm owner))->require_totp && !$pqcm ? 1 : 0,
    );
    return;
}

sub internal_validate_new {
    my($self) = @_;
    if (my $err = $self->get('realm_owner')->validate_password($self->get('new_password'))) {
        $self->internal_put_error(new_password => $err);
    }
    return;
}

sub internal_validate_old {
    my($self) = @_;
    return $self->internal_put_error(qw(old_password PASSWORD_MISMATCH))
        unless $_P->is_equal(
            $self->get_nested(qw(realm_owner password)),
            $self->get('old_password'),
        );
    return 1;
}

sub validate {
    my($self) = @_;
    return if $self->in_error;
    $self->SUPER::validate
        if $self->get('require_totp');
    if ($self->get('require_old_password')) {
        return
            unless $self->validate_not_null('old_password')
            && $self->internal_validate_old;
    }
    return $self->internal_put_error(qw(confirm_new_password CONFIRM_PASSWORD))
        unless $self->get('new_password') eq $self->get('confirm_new_password');
    $self->internal_validate_new;
    return;
}

1;
