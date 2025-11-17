# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserLoginMFABaseForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_A) = b_use('Action.Acknowledgement');
my($_AAC) = b_use('Action.AccessChallenge');
my($_C) = b_use('AgentHTTP.Cookie');
my($_MM) = b_use('Type.MFAMethod');
my($_TAC) = b_use('Type.AccessCode');
my($_TACS) = b_use('Type.AccessCodeStatus');
my($_UAC) = b_use('Model.UserAccessCode');
my($_ULF) = b_use('Model.UserLoginForm');

sub MFA_RECOVERY_CODE_FIELD {
    return 'rc';
}

sub SENSITIVE_FIELDS {
    return ['mfa_recovery_code'];
}

sub bypass_challenge {
    shift->internal_put_field(bypass_challenge => 1);
    return;
}

sub delete_cookie {
    my($proto, $cookie) = @_;
    $cookie->delete(
        $proto->MFA_RECOVERY_CODE_FIELD,
    );
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->internal_set_cookie;
    $_ULF->set_user($self->get('realm_owner'), $self->ureq('cookie'), $self->req);
    return
        unless $self->get('realm_owner');
    unless ($self->unsafe_get('bypass_challenge')) {
        $_AAC->assert_challenge($self->req, {
            type => $_TAC->ESCALATION_CHALLENGE,
            status => $_TACS->PENDING,
        })->update({status => $_TACS->PASSED});
    }
    my($next);
    if (my $mrcm = $self->unsafe_get('mfa_recovery_code_model')) {
        $mrcm->update({status => $_TACS->ARCHIVED});
        $_A->save_label(mfa_recovery_code_used => $self->req);
        $next = 'refill_task';
    }
    $next ||= $_AAC->get_next($self->req);
    return {
        method => 'server_redirect',
        task_id => $next,
        no_context => 1,
    } if $next;
    return;
}

sub internal_clear_sensitive_fields {
    my($self) = @_;
    foreach my $f (@{$self->SENSITIVE_FIELDS}) {
        $self->internal_put_field($f => undef);
        $self->internal_clear_literal($f);
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        $self->field_decl(
            visible => [
                [qw(mfa_recovery_code Line)],
                [qw(disable_mfa Boolean)],
            ],
            other => [
                [qw(realm_owner Model.RealmOwner)],
                [qw(mfa_recovery_code_model Model.UserAccessCode)],
                [qw(do_logout Boolean)],
                [qw(bypass_challenge Boolean)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my($self) = @_;
    return
        unless $self->ureq('cookie');
    if ($self->unsafe_get('do_logout')) {
        $self->internal_put_field(realm_owner => undef);
        return;
    }
    $self->internal_put_field(
        realm_owner => $_ULF->load_cookie_user($self->req, $self->req('cookie')));
    b_die('FORBIDDEN')
        unless $self->get('realm_owner')
        && $self->get('realm_owner')->get_configured_mfa_methods($_MM->TOTP);
    return
        if $self->unsafe_get('bypass_challenge');
    $_AAC->unauth_assert_challenge($self->req, {
        user_id => $self->get_nested(qw(realm_owner realm_id)),
        type => $_TAC->LOGIN_CHALLENGE,
        status => $_TACS->PASSED,
    });
    return;
}

sub internal_set_cookie {
    my($self) = @_;
    my($cookie) = $self->ureq('cookie');
    return undef
        unless $cookie;
    $self->delete_cookie($cookie);
    if ($self->get('realm_owner')) {
        $_C->assert_is_ok($self->req);
        if ($self->unsafe_get('mfa_recovery_code')) {
            $cookie->put($self->MFA_RECOVERY_CODE_FIELD => $self->get('mfa_recovery_code'));
            return $cookie;
        }
    }
    return undef;
}

sub is_valid_cookie {
    my($proto, $cookie, $auth_user) = @_;
    if (my $c = $cookie->unsafe_get($proto->MFA_RECOVERY_CODE_FIELD)) {
        return $_UAC->is_valid_cookie_code($auth_user->get('realm_id'), $c);
    }
    return 0;
}

sub validate {
    my($self, $realm_owner, $mfa_recovery_code) = @_;
    if (defined($realm_owner) && defined($mfa_recovery_code)) {
        $self->internal_put_field(realm_owner => $realm_owner);
        $self->internal_put_field(mfa_recovery_code => $mfa_recovery_code);
    }
    _validate_recovery_code($self);
    return;
}

sub _validate_recovery_code {
    my($self) = @_;
    if ($self->get('mfa_recovery_code')) {
        my($v, $e) = $_TAC->MFA_RECOVERY->from_literal_for_type($self->get('mfa_recovery_code'));
        if ($v && (my $sc = $self->new_other('UserAccessCode')->unauth_load_by_code($v, {
            user_id => $self->get_nested(qw(realm_owner realm_id)),
            type => $_TAC->MFA_RECOVERY,
            status => $_TACS->ACTIVE,
        }))) {
            $self->internal_put_field(mfa_recovery_code_model => $sc);
            return;
        }
        elsif ($e) {
            $self->internal_put_error(mfa_recovery_code => $e);
        }
        else {
            $self->internal_put_error(mfa_recovery_code => 'INVALID_MFA_RECOVERY_CODE');
        }
        # Need to stay on page or the login attempt would get rolled back
        $self->internal_stay_on_page;
        return;
    }
    return;
}

1;
