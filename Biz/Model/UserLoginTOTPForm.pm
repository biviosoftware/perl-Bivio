# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserLoginTOTPForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_C) = b_use('AgentHTTP.Cookie');
my($_RCT) = b_use('Type.RecoveryCode');
my($_ULF) = b_use('Model.UserLoginForm');
my($_UPQ) = b_use('Action.UserPasswordQuery');

sub TOTP_CODE_FIELD {
    return 'tc';
}

sub TOTP_TIME_STEP_FIELD {
    return 'tt';
}

sub FALLBACK_CODE_FIELD {
    return 'fc';
}

sub execute_ok {
    my($self) = @_;
    my($cookie) = $self->set_cookie_totp($self->get('realm_owner'));
    $_ULF->set_user($self->get('realm_owner'), $cookie, $self->req);
    my($next);
    if ($self->unsafe_get('password_query_code')) {
        $_UPQ->new({
            realm_owner => $self->get('realm_owner'),
            password_query_code => $self->get('password_query_code'),
        })->put_on_request($self->req, 1);
        $next = 'password_task';
    }
    if (my $tlrcm = $self->unsafe_get('fallback_code_model')) {
        $self->get('disable_totp') ? $self->internal_disable_totp : $tlrcm->set_used;
        $next = 'refill_task';
    }
    return $next ? {
        method => 'server_redirect',
        task_id => $next,
        # TODO: need this?
        no_context => 1,
    } : ();
}

sub internal_disable_totp {
    my($self) = @_;
    $self->req('Model.UserTOTP')->delete;
    $self->req('Model.MFAFallbackCodeList')->do_rows(sub {
        my($it) = @_;
        $self->new_other('UserRecoveryCode')->load({
            user_recovery_code_id => $it->get('UserRecoveryCode.user_recovery_code_id'),
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
                [qw(fallback_code Line)],
                [qw(disable_totp Boolean)],
            ],
            hidden => [
                [qw(password_query_code SecretLine)],
            ],
            other => [
                [qw(realm_owner Model.RealmOwner)],
                [qw(totp_time_step Integer)],
                [qw(fallback_code_model Model.UserRecoveryCode)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my($self) = @_;
    if (my $upq = $self->ureq('Action.UserPasswordQuery')) {
        $self->internal_put_field(
            password_query_code => $upq->get('password_query_code'));
    }
    return
        unless $self->ureq('cookie');
    $self->internal_put_field(
        realm_owner => $_ULF->load_cookie_user($self->req, $self->req('cookie')));
    return
        unless $self->get('realm_owner');
    # TODO: do we need these?
    b_die('USER_LOCKED_OUT')
        if $self->get('realm_owner')->is_locked_out;
    b_die('NOT_FOUND')
        unless $self->get('realm_owner')->require_totp;
    return;
}

sub is_valid_totp_cookie {
    my($proto, $cookie, $auth_user) = @_;
    return 0
        unless $auth_user;
    return 1
        unless $auth_user->require_totp;
    if (my $c = $cookie->unsafe_get($proto->TOTP_CODE_FIELD)) {
        if (my $t = $cookie->unsafe_get($proto->TOTP_TIME_STEP_FIELD)) {
            return $auth_user->new_other('UserTOTP')
                ->is_valid_for_cookie($auth_user->get('realm_id'), $c, $t);
        }
        b_warn('invalid totp cookie fields');
        return 0;
    }
    if (my $c = $cookie->unsafe_get($proto->FALLBACK_CODE_FIELD)) {
        return $auth_user->new_other('UserRecoveryCode')
            ->is_valid_for_cookie($auth_user->get('realm_id'), $c);
    }
    $proto->delete_cookie($cookie);
    return 0;
}

sub set_cookie_totp {
    my($self, $values) = @_;
    my($cookie) = $self->ureq('cookie');
    return undef
        unless $cookie;
    $self->internal_put_field(%$values)
        if ref($values) eq 'HASH';
    if ($self->get('realm_owner')) {
        $_C->assert_is_ok($self->req);
        if ($self->get('totp_code')) {
            $cookie->put(
                $self->TOTP_CODE_FIELD => $self->get('totp_code'),
                $self->TOTP_TIME_STEP_FIELD => $self->get('totp_time_step'),
            );
            return $cookie;
        }
        if ($self->get('fallback_code')) {
            $cookie->put($self->FALLBACK_CODE_FIELD => $self->get('fallback_code'));
            return $cookie;
        }
        b_die('set cookie totp with no codes');
        # DOES NOT RETURN
    }
    _delete_cookie($self, $cookie);
    return $cookie;
}

sub validate {
    my($self, $values) = @_;
    $self->internal_put_field(%$values)
        if ref($values) eq 'HASH';
    # else $values=$form_button
    _validate_totp($self);
    if ($self->in_error) {
        foreach my $f ('totp_code', 'fallback_code') {
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
        $self->FALLBACK_CODE_FIELD,
    );
    return;
}

sub _validate_totp {
    my($self) = @_;
    if ($self->get('totp_code')) {
        my($totp) = $self->new_other('UserTOTP');
        if ($totp->unauth_load_or_die({
            $totp->REALM_ID_FIELD => $self->get_nested(qw(realm_owner realm_id)),
        })->is_valid_input_code($self->get('totp_code'))) {
            $self->internal_put_field(totp_time_step => $totp->get('last_time_step'));
            return;
        }
        # Need to stay on page or the login attempt would get rolled back
        $self->internal_stay_on_page;
        $self->internal_put_error(totp_code => 'INVALID_TOTP_CODE');
        return;
    }
    if ($self->get('fallback_code')) {
        # TODO: could use MFAFallbackCodeList here
        if (my $rc = $self->new_other('UserRecoveryCode')->unauth_load_by_code_and_type(
            $self->get_nested(qw(realm_owner realm_id)),
            $self->get('fallback_code'),
            $_RCT->MFA_FALLBACK,
        )) {
            $self->internal_put_field(fallback_code_model => $rc);
            return;
        }
        # Need to stay on page or the login attempt would get rolled back
        $self->internal_stay_on_page;
        $self->internal_put_error(fallback_code => 'INVALID_RECOVERY_CODE');
        return;
    }
    $self->internal_put_error(totp_code => 'NULL');
    return;
}

1;
