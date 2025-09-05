# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserLoginTOTPForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_C) = b_use('AgentHTTP.Cookie');
my($_RCT) = b_use('Type.RecoveryCodeType');
my($_ULF) = b_use('Model.UserLoginForm');
my($_UPQ) = b_use('Action.UserPasswordQuery');

sub TOTP_CODE_FIELD {
    return 'tc';
}

sub TOTP_TIME_STEP_FIELD {
    return 'tt';
}

sub TOTP_LOST_RECOVERY_CODE_FIELD {
    return 'tr';
}

sub execute_empty {
    my($self) = @_;
    return $self->internal_validate_realm_owner;
}

sub execute_ok {
    my($self) = @_;
    my($cookie) = _set_cookie_totp($self);
    $_ULF->set_user($self->get('realm_owner'), $cookie, $self->req);
    if (my $tlrcm = $self->unsafe_get('totp_lost_recovery_code_model')) {
        $self->get('disable_totp') ? $self->internal_disable_totp : $tlrcm->set_expired;
        return 'refill_task'
    }
    if ($self->unsafe_get('password_query_recovery_code')) {
        $_UPQ->new({
            realm_owner => $self->get('realm_owner'),
            password_query_recovery_code => $self->get('password_query_recovery_code'),
        })->put_on_request($self->req, 1);
        return {
            method => 'server_redirect',
            task_id => $self->req('task')->get_attr_as_id('password_task'),
            no_context => 1,
        };
    }
    return;
}

sub internal_disable_totp {
    my($self) = @_;
    b_die('models not loaded')
        unless $self->internal_load_models($self);
    $self->req('Model.TOTP')->delete;
    $self->req('Model.RecoveryCodeList')->do_rows(sub {
        my($it) = @_;
        $self->new_other('RecoveryCode')->load({
            recovery_code_id => $it->get('RecoveryCode.recovery_code_id'),
        })->delete;
        return 1;
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        $self->field_decl(
            visible => [
                [qw(totp_code Line)],
                [qw(totp_lost_recovery_code Line)],
                [qw(disable_totp Boolean)],
            ],
            hidden => [
                [qw(password_query_recovery_code Line)],
            ],
            other => [
                [qw(realm_owner Model.RealmOwner)],
                [qw(totp_time_step Integer)],
                [qw(totp_lost_recovery_code_model Model.RecoveryCode)],
                [qw(do_locked_out_task Boolean)],
            ],
        ),
    });
}

sub internal_load_models {
    my($self) = @_;
    return 1
        if $self->ureq('Model.TOTP') && $self->ureq('Model.RecoveryCodeList');
    return 0
        unless $self->new_other('TOTP')->unsafe_load;
    return 0
        unless $self->new_other('RecoveryCodeList')->load_all({
            type => $_RCT->TOTP_LOST,
        })->get_result_set_size;
    return 1;
}

sub internal_pre_execute {
    my($self) = @_;
    if (my $upq = $self->ureq('Action.UserPasswordQuery')) {
        $self->internal_put_field(
            password_query_recovery_code => $upq->get('password_query_recovery_code'));
    }
    return
        unless $self->ureq('cookie');
    $self->internal_put_field(
        realm_owner => $_ULF->load_cookie_user($self->req, $self->req('cookie')));
    return;
}

sub internal_validate_realm_owner {
    my($self) = @_;
    b_die('FORBIDDEN')
        unless $self->get('realm_owner');
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
            return $auth_user->new_other('TOTP')
                ->is_valid_for_cookie($auth_user->get('realm_id'), $c, $t);
        }
        b_warn('invalid totp cookie fields');
        return 0;
    }
    if (my $c = $cookie->unsafe_get($proto->TOTP_LOST_RECOVERY_CODE_FIELD)) {
        return $auth_user->new_other('RecoveryCode')
            ->is_valid_for_cookie($auth_user->get('realm_id'), $c);
    }
    _delete_cookie($proto, $cookie);
    return 0;
}

sub validate {
    my($self) = @_;
    $self->internal_validate_realm_owner;
    _validate_totp($self);
    if ($self->in_error) {
        foreach my $f ('totp_code', 'totp_lost_recovery_code') {
            $self->internal_put_field($f => undef);
            $self->internal_clear_literal($f);
        }
        $self->internal_put_field(do_locked_out_task => 1)
            if $_ULF->record_login_attempt($self->get('realm_owner'), 0)->is_state_locked_out;
    }
    else {
        $_ULF->record_login_attempt($self->get('realm_owner'), 1);
    }
    return;
}

sub validate_and_execute_ok {
    return shift->delegate_method($_ULF, @_);
}

sub _delete_cookie {
    my($proto, $cookie) = @_;
    $cookie->delete(
        $proto->TOTP_CODE_FIELD,
        $proto->TOTP_TIME_STEP_FIELD,
        $proto->TOTP_LOST_RECOVERY_CODE_FIELD,
    );
    return;
}

sub _set_cookie_totp {
    my($self) = @_;
    my($cookie) = $self->req->unsafe_get('cookie');
    return undef
        unless $cookie;
    if ($self->get('realm_owner')) {
        $_C->assert_is_ok($self->req);
        if ($self->get('totp_code')) {
            $cookie->put(
                $self->TOTP_CODE_FIELD => $self->get('totp_code'),
                $self->TOTP_TIME_STEP_FIELD => $self->get('totp_time_step'),
            );
            return $cookie;
        }
        if ($self->get('totp_lost_recovery_code')) {
            $cookie->put($self->TOTP_LOST_RECOVERY_CODE_FIELD => $self->get('totp_lost_recovery_code'));
            return $cookie;
        }
        b_die('set cookie totp with no codes');
        # DOES NOT RETURN
    }
    _delete_cookie($self, $cookie);
    return $cookie;
}

sub _validate_totp {
    my($self) = @_;
    if ($self->get('totp_code')) {
        my($totp) = $self->new_other('TOTP');
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
    if ($self->get('totp_lost_recovery_code')) {
        if (my $rc = $self->new_other('RecoveryCode')->unauth_load_by_code_and_type(
            $self->get_nested(qw(realm_owner realm_id)),
            $self->get('totp_lost_recovery_code'),
            $_RCT->TOTP_LOST,
        )) {
            $self->internal_put_field(totp_lost_recovery_code_model => $rc);
            return;
        }
        # Need to stay on page or the login attempt would get rolled back
        $self->internal_stay_on_page;
        $self->internal_put_error(totp_lost_recovery_code => 'INVALID_RECOVERY_CODE');
        return;
    }
    $self->internal_put_error(totp_code => 'NULL');
    return;
}

1;
