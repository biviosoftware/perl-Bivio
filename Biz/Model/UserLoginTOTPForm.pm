# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserLoginTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginMFABaseForm';

my($_AMC) = b_use('Action.MFAChallenge');
my($_C) = b_use('AgentHTTP.Cookie');
my($_DT) = b_use('Type.DateTime');
my($_MM) = b_use('Type.MFAMethod');
my($_RFC6238) = b_use('Biz.RFC6238');
my($_TSC) = b_use('Type.SecretCode');
my($_TSCS) = b_use('Type.SecretCodeStatus');
my($_ULF) = b_use('Model.UserLoginForm');
my($_USC) = b_use('Model.UserSecretCode');
my($_UT) = b_use('Model.UserTOTP');

sub TOTP_CODE_FIELD {
    return 'tc';
}

sub TOTP_TIME_STEP_FIELD {
    return 'tt';
}

sub SENSITIVE_FIELDS {
    return [qw(totp_code)];
}

sub delete_cookie {
    my($proto, $cookie) = @_;
    shift->SUPER::delete_cookie(@_);
    $cookie->delete(
        $proto->TOTP_CODE_FIELD,
        $proto->TOTP_TIME_STEP_FIELD,
    );
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        $self->field_decl(
            visible => [
                [qw(totp_code Line)],
            ],
            other => [
                [qw(totp_time_step Integer)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my($res) = shift->SUPER::internal_pre_execute(@_);
    return $res
        if $res || !$self->unsafe_get('realm_owner');
    _totp_model($self);
    return $res;
}

sub internal_set_cookie {
    my($self) = @_;
    return undef
        unless $self->ureq('cookie');
    my($cookie) = shift->SUPER::internal_set_cookie(@_);
    return $cookie
        if $cookie;
    $cookie = $self->req('cookie');
    $self->delete_cookie($cookie);
    if ($self->get('realm_owner')) {
        $_C->assert_is_ok($self->req);
        if ($self->unsafe_get('totp_code')) {
            $cookie->put(
                $self->TOTP_CODE_FIELD => $self->get('totp_code'),
                $self->TOTP_TIME_STEP_FIELD => $self->get('totp_time_step'),
            );
            return $cookie;
        }
        if ($self->req->is_substitute_user || $self->unsafe_get('bypass_challenge')) {
            my($totp) = _totp_model($self);
            my($ts) = $_RFC6238->get_time_step($_DT->to_unix($_DT->now), $totp->get('period'));
            $cookie->put(
                $self->TOTP_CODE_FIELD => $_RFC6238->compute(
                    $totp->get(qw(algorithm digits secret)), $ts),
                $self->TOTP_TIME_STEP_FIELD => $ts,
            );
            return $cookie;
        }
        b_die('set cookie with no codes');
        # DOES NOT RETURN
    }
    return $cookie;
}

sub is_valid_cookie {
    my($proto, $cookie, $auth_user) = @_;
    my($res) = shift->SUPER::is_valid_cookie(@_);
    return $res
        if $res;
    if (my $c = $cookie->unsafe_get($proto->TOTP_CODE_FIELD)) {
        if (my $t = $cookie->unsafe_get($proto->TOTP_TIME_STEP_FIELD)) {
            return $_UT->is_valid_cookie_code($auth_user->get('realm_id'), $c, $t);
        }
        b_warn('invalid totp cookie fields');
        return 0;
    }
    return 0;
}

sub validate {
    my($self, $realm_owner, $mfa_recovery_code, $totp_code) = @_;
    shift->SUPER::validate(@_);
    if (defined($totp_code)) {
        $self->internal_put_field(totp_code => $totp_code);
    }
    _validate_totp_code($self);
    if ($self->in_error) {
        $self->internal_clear_sensitive_fields;
        $_ULF->record_login_attempt($self->get('realm_owner'), 0);
        return;
    }
    elsif (!$self->get('totp_code') && !$self->get('mfa_recovery_code')) {
        $self->internal_put_error(totp_code => 'NULL');
        return;
    }
    $_ULF->record_login_attempt($self->get('realm_owner'), 1);
    return;
}

sub _totp_model {
    my($self) = @_;
    my($m) = $self->new_other('UserTOTP');
    return $m->unauth_load_or_die({
        $m->REALM_ID_FIELD => $self->get_nested(qw(realm_owner realm_id)),
    });
}

sub _validate_totp_code {
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
    return;
}

1;
