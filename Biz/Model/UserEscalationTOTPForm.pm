# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserEscalationTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginTOTPForm';

my($_AAC) = b_use('Action.AccessChallenge');
my($_TAC) = b_use('Type.AccessCode');
my($_TACS) = b_use('Type.AccessCodeStatus');

sub SENSITIVE_FIELDS {
    return ['RealmOwner.password', @{shift->SUPER::SENSITIVE_FIELDS}],
}

sub execute_ok {
    my($self) = @_;
    $_AAC->assert_challenge($self->req, {
        type => $_TAC->ESCALATION_CHALLENGE,
        status => $_TACS->PENDING,
    })->update({status => $_TACS->PASSED});
    return;
}

sub execute_cancel {
    # Discard context so we don't return to a form that requires escalation and get redirected here
    # again.
    return 'cancel';
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
    $self->new_other('UserTOTP')->load;
    $_AAC->assert_challenge($self->req, {
        type => $_TAC->ESCALATION_CHALLENGE,
        status => $_TACS->PENDING,
    });
    $self->internal_put_field(realm_owner => $self->req(qw(auth_realm owner)));
    return;
}

sub validate {
    my($self) = @_;
    return
        if $self->in_error;
    my($ulf) = $self->internal_login_form->new($self->req);
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
