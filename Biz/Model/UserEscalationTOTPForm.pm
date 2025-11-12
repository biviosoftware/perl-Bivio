# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserEscalationTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginTOTPForm';

my($_AMC) = b_use('Action.MFAChallenge');
my($_TSC) = b_use('Type.SecretCode');
my($_TSCS) = b_use('Type.SecretCodeStatus');
my($_UT) = b_use('Model.UserTOTP');

sub SENSITIVE_FIELDS {
    return ['RealmOwner.password', @{shift->SUPER::SENSITIVE_FIELDS}],
}

sub execute_ok {
    my($self) = @_;
    $_AMC->get_challenge($self->req, {
        type => $_TSC->ESCALATION_CHALLENGE,
        status => $_TSCS->PENDING,
    })->update({status => $_TSCS->PASSED});
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
        visible => [{
            name => 'RealmOwner.password',
            constraint => 'NOT_NULL',
        }],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    # Assert that we have TOTP configured
    b_debug($self->req);
    $self->new_other('UserTOTP')->load;
    my($sc) = $_AMC->get_challenge($self->req, {
        type => $_TSC->ESCALATION_CHALLENGE,
        status => $_TSCS->PENDING,
    });
    b_die('FORBIDDEN')
        unless $sc && $sc->get('user_id') eq $self->req('auth_id');
    $self->internal_put_field(realm_owner => $self->req(qw(auth_realm owner)));
    return;
}

sub validate {
    my($self) = @_;
    return
        if $self->in_error;
    my($ulf) = $self->new_other('UserLoginForm');
    # Only recording plain login attempt in error because recording success would prevent
    # lockouts when password is correct, but totp code is not.
    $ulf->validate($self->get_nested(qw(realm_owner name)), $self->get('RealmOwner.password'), 1);
    if ($ulf->in_error) {
        # Need to stay on page or the login attempt would get rolled back
        $self->internal_stay_on_page;
        my($e) = $ulf->get_errors;
        $self->internal_put_error('RealmOwner.password' => delete($e->{'RealmOwner.password'}));
        b_die('invalid login=', $self->get('realm_owner'), ' ', $e)
            if %$e;
        $self->internal_clear_sensitive_fields;
        $ulf->record_login_attempt($self->get('realm_owner'), 0);
        # Need to return in error so that TOTP code last_time_step doesn't get updated
        return;
    }
    shift->SUPER::validate(@_);
    return;
}

1;
