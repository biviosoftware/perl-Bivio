# Copyright (c) 2003-2023 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserPasswordForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_A) = b_use('Action.Acknowledgement');
my($_P) = b_use('Type.Password');
my($_SC) = b_use('Type.SecretCode');
my($_ULTF) = b_use('Model.UserLoginTOTPForm');

sub PASSWORD_FIELD_LIST {
    return qw(new_password old_password confirm_new_password);
}

sub execute_ok {
    my($self) = shift;
    # Updates the password in the database and the cookie.
    $self->get_instance('UserLoginForm')->execute($self->req, {
        realm_owner => $self->get('realm_owner')
            ->update_password($self->get('new_password')),
    });
    $self->get('password_reset_code_model')->set_used
        if $self->unsafe_get('password_reset_code_model');
    if ($self->unsafe_get('require_mfa')) {
        $self->get('totp_form')->bypass_challenge;
        return $self->get('totp_form')->process($self->req);
    }
    return;
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
                [qw(totp_code Line NONE)],
                [qw(mfa_recovery_code Line NONE)],
            ],
            hidden => [
                [qw(password_reset_code SecretLine NONE)],
            ],
            other => [
                [qw(require_old_password Boolean)],
                [qw(password_reset_code_model Model.UserSecretCode NONE)],
                [qw(require_mfa Boolean)],
                [qw(totp_form Model.UserLoginTOTPForm NONE)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my($self, $method) = @_;
    # Sets the 'require_old_password' field based on if the user is the
    # super user.
    unless ($self->get('password_reset_code')) {
        $self->internal_put_field(
            password_reset_code => $self->ureq(qw(Action.UserPasswordQuery password_reset_code)),
        );
    }
    my($prsc);
    if ($self->get('password_reset_code')) {
        $prsc = $self->new_other('UserSecretCode')->unsafe_load_by_code_and_type(
            $self->get('password_reset_code'),
            $_SC->PASSWORD_RESET,
        );
        if ($prsc) {
            $self->internal_put_field(password_reset_code_model => $prsc);
        }
        else {
            $_A->save_label(password_nak => $self->req);
            b_die('NOT_FOUND');
            # DOES NOT RETURN
        }
    }
    $self->internal_put_field(
        password_reset_code => $prsc ? $prsc->get('code') : undef,
        realm_owner => $self->req(qw(auth_realm owner)),
        require_old_password => $prsc || $self->req->is_substitute_user ? 0 : 1,
        require_mfa => $self->req(qw(auth_realm owner))->require_mfa && !$prsc ? 1 : 0,
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
    return
        if $self->in_error;
    if ($self->get('require_mfa')) {
        # Only TOTP supported at this time; may support other MFA methods later.
        my($ultf) = $self->new_other('UserLoginTOTPForm');
        my($totp_fields) = [qw(realm_owner totp_code mfa_recovery_code)];
        $ultf->validate(map($self->get($_) // '', @$totp_fields));
        if ($ultf->in_error) {
            # Need to stay on page or the login attempt would get rolled back
            $self->internal_stay_on_page;
            my($e) = $ultf->get_errors;
            foreach my $f (@$totp_fields) {
                $self->internal_put_error($f => delete($e->{$f}));
            }
            b_die('remaining error(s)=', ' ', $e)
                if %$e;
        }
        $self->internal_put_field(totp_form => $ultf);
    }
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
