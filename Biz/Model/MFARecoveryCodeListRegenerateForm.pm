# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::MFARecoveryCodeListRegenerateForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_AMC) = b_use('Action.MFAChallenge');
my($_AMRCL) = b_use('Action.MFARecoveryCodeList');
my($_TSC) = b_use('Type.SecretCode');

sub execute_ok {
    my($self) = @_;
    # TODO: send email
    unless ($self->ureq('Model.MFARecoveryCodeList')) {
        $_AMRCL->regenerate_list($self->req);
        $self->internal_stay_on_page;
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
    });
}

sub internal_pre_execute {
    my($self) = @_;
    # TODO: get challenge this way or via unsafe_get_challenge?
    my($c) = $self->ureq($_AMC->get_req_key($_TSC->ESCALATION_CHALLENGE));
    b_die('FORBIDDEN')
        unless $c && $c->get('user_id') eq $self->req('auth_id') && $c->get('status')->eq_passed;
    b_die('regenerate recovery codes with no MFA methods')
        unless $self->req(qw(auth_realm owner))->get_configured_mfa_methods;
    return;
}

1;
