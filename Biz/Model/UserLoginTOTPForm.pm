# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserLoginTOTPForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_A) = b_use('Action.Acknowledgement');
my($_C) = b_use('AgentHTTP.Cookie');
my($_DT) = b_use('Type.DateTime');
my($_RFC6238) = b_use('Biz.RFC6238');
my($_TSC) = b_use('Type.SecretCode');
my($_ULF) = b_use('Model.UserLoginForm');
my($_UPQ) = b_use('Action.UserPasswordQuery');
my($_USC) = b_use('Model.UserSecretCode');

sub TOTP_CODE_FIELD {
    return 'tc';
}

sub TOTP_TIME_STEP_FIELD {
    return 'tt';
}

sub MFA_RECOVERY_CODE_FIELD {
    return 'rc';
}

sub execute_ok {
    my($self) = @_;
    my($cookie) = _set_cookie_totp($self, $self->get('realm_owner'));
    # TODO: not sure if this works with substitute user logout, but user has to be set to use refill task. Should that be a task, or just do it here?
    $_ULF->set_user($self->get('realm_owner'), $cookie, $self->req);
    my($next);
    if (my $pmccm = $self->unsafe_get('password_mfa_challenge_code_model')) {
        $pmccm->set_used;
        $_UPQ->new({
            password_reset_code => $self->new_other('UserSecretCode')->create({
                $_USC->REALM_ID_FIELD => $self->get_nested(qw(realm_owner realm_id)),
                type => $_TSC->PASSWORD_RESET,
            })->get('code'),
        })->put_on_request($self->req, 1);
        $next = 'password_task';
    }
    if (my $mrcm = $self->unsafe_get('mfa_recovery_code_model')) {
        $self->get('disable_mfa') ? $self->internal_disable_mfa : $mrcm->set_archived;
        $_A->save_label(mfa_recovery_code_used => $self->req);
        $next = 'refill_task';
    }
    return $next ? {
        method => 'server_redirect',
        task_id => $next,
        # TODO: need this?
        no_context => 1,
    } : 0;
}

sub internal_disable_mfa {
    my($self) = @_;
    # TODO: test this
    $self->req('Model.UserTOTP')->delete;
    $self->req('Model.MFARecoveryCodeList')->do_rows(sub {
        my($it) = @_;
        $self->new_other('UserSecretCode')->set_ephemeral->load({
            user_secret_code_id => $it->get('UserSecretCode.user_secret_code_id'),
        })->delete;
        return 1;
    });
    _delete_cookie($self, $self->req('cookie'));
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        $self->field_decl(
            visible => [
                [qw(totp_code Line)],
                [qw(mfa_recovery_code Line)],
                [qw(disable_mfa Boolean)],
            ],
            hidden => [
                [qw(password_mfa_challenge_code SecretLine)],
            ],
            other => [
                [qw(realm_owner Model.RealmOwner)],
                [qw(totp_time_step Integer)],
                [qw(mfa_recovery_code_model Model.UserSecretCode)],
                [qw(password_mfa_challenge_code_model Model.UserSecretCode)],
            ],
        ),
    });
}

sub internal_load_models {
    my($self) = @_;
    _totp_model($self);
    $self->new_other('MFARecoveryCodeList')->unauth_load_all({
        auth_id => $self->get_nested(qw(realm_owner realm_id)),
    });
    return 1;
}

sub internal_pre_execute {
    my($self) = @_;
    return
        unless $self->ureq('cookie');
    $self->internal_put_field(
        realm_owner => $_ULF->load_cookie_user($self->req, $self->req('cookie')));
    return
        unless $self->get('realm_owner');
    b_die('USER_LOCKED_OUT')
        if $self->get('realm_owner')->is_locked_out;
    $self->internal_load_models;
    unless ($self->unsafe_get('password_mfa_challenge_code')) {
        $self->internal_put_field(
            password_mfa_challenge_code => $self->ureq(qw(Action.UserPasswordQuery password_mfa_challenge_code)),
        );
    }
    if ($self->get('password_mfa_challenge_code')) {
        if (my $sc = $self->new_other('UserSecretCode')->unauth_load_by_code_and_type(
            $self->get_nested(qw(realm_owner realm_id)),
            $self->get('password_mfa_challenge_code'),
            $_TSC->PASSWORD_MFA_CHALLENGE,
        )) {
            $self->internal_put_field(password_mfa_challenge_code_model => $sc);
            return;
        }
        $_A->save_label(password_nak => $self->req);
        b_die('NOT_FOUND');
    }
    return;
}

sub is_valid_totp_cookie {
    my($proto, $cookie, $auth_user) = @_;
    if (my $c = $cookie->unsafe_get($proto->TOTP_CODE_FIELD)) {
        if (my $t = $cookie->unsafe_get($proto->TOTP_TIME_STEP_FIELD)) {
            return $auth_user->new_other('UserTOTP')
                ->is_valid_for_cookie($auth_user->get('realm_id'), $c, $t);
        }
        b_warn('invalid totp cookie fields');
        return 0;
    }
    if (my $c = $cookie->unsafe_get($proto->MFA_RECOVERY_CODE_FIELD)) {
        return $auth_user->new_other('UserSecretCode')
            ->is_valid_for_cookie($auth_user->get('realm_id'), $c);
    }
    return 0;
}

sub validate {
    my($self, $realm_owner, $totp_code, $mfa_recovery_code) = @_;
    if (defined($realm_owner) && defined($totp_code)) {
        $self->internal_put_field(realm_owner => $realm_owner);
        $self->internal_put_field(totp_code => $totp_code);
        $self->internal_put_field(mfa_recovery_code => $mfa_recovery_code);
    }
    _validate_totp($self);
    if ($self->in_error) {
        foreach my $f ('totp_code', 'mfa_recovery_code') {
            $self->internal_put_field($f => undef);
            $self->internal_clear_literal($f);
        }
        $_ULF->record_login_attempt($self->get('realm_owner'), 0);
        return;
    }
    $_ULF->record_login_attempt($self->get('realm_owner'), 1);
    return;
}

sub _delete_cookie {
    my($self, $cookie) = @_;
    $cookie->delete(
        $self->TOTP_CODE_FIELD,
        $self->TOTP_TIME_STEP_FIELD,
        $self->MFA_RECOVERY_CODE_FIELD,
    );
    return;
}

sub _set_cookie_totp {
    my($self, $values) = @_;
    my($cookie) = $self->ureq('cookie');
    return undef
        unless $cookie;
    if ($self->get('realm_owner')) {
        $_C->assert_is_ok($self->req);
        if ($self->unsafe_get('totp_code')) {
            $cookie->put(
                $self->TOTP_CODE_FIELD => $self->get('totp_code'),
                $self->TOTP_TIME_STEP_FIELD => $self->get('totp_time_step'),
            );
            return $cookie;
        }
        if ($self->unsafe_get('mfa_recovery_code')) {
            $cookie->put($self->MFA_RECOVERY_CODE_FIELD => $self->get('mfa_recovery_code'));
            return $cookie;
        }
        if ($self->req->is_substitute_user) {
            my($totp) = _totp_model($self);
            my($ts) = $_RFC6238->get_time_step($_DT->to_unix($_DT->now), $totp->get('period'));
            $cookie->put(
                $self->TOTP_CODE_FIELD => $_RFC6238->compute(
                    $totp->get(qw(algorithm digits secret)), $ts),
                $self->TOTP_TIME_STEP_FIELD => $ts,
            );
            return $cookie;
        }
        b_die('set cookie totp with no codes');
        # DOES NOT RETURN
    }
    _delete_cookie($self, $cookie);
    return $cookie;
}

sub _totp_model {
    my($self) = @_;
    my($m) = $self->new_other('UserTOTP');
    return $m->unauth_load_or_die({
        $m->REALM_ID_FIELD => $self->get_nested(qw(realm_owner realm_id)),
    });
}

sub _validate_totp {
    my($self) = @_;
    if ($self->get('totp_code')) {
        my($totp) = _totp_model($self);
        if ($totp->is_valid_input_code($self->get('totp_code'))) {
            $self->internal_put_field(totp_time_step => $totp->get('last_time_step'));
            return;
        }
        # Need to stay on page or the login attempt would get rolled back
        $self->internal_stay_on_page;
        $self->internal_put_error(totp_code => 'INVALID_TOTP_CODE');
        return;
    }
    if ($self->get('mfa_recovery_code')) {
        if (my $sc = $self->new_other('UserSecretCode')->unauth_load_by_code_and_type(
            $self->get_nested(qw(realm_owner realm_id)),
            $self->get('mfa_recovery_code'),
            $_TSC->MFA_RECOVERY,
        )) {
            $self->internal_put_field(mfa_recovery_code_model => $sc);
            return;
        }
        # Need to stay on page or the login attempt would get rolled back
        $self->internal_stay_on_page;
        $self->internal_put_error(mfa_recovery_code => 'INVALID_MFA_RECOVERY_CODE');
        return;
    }
    $self->internal_put_error(totp_code => 'NULL');
    return;
}

1;
