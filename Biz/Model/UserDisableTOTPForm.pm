# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserDisableTOTPForm;
use strict;
use Bivio::Base 'Model.UserEscalatedAccessBaseForm';

my($_ULTF) = b_use('Model.UserLoginTOTPForm');
my($_UT) = b_use('Model.UserTOTP');

sub execute_ok {
    my($self) = @_;
    shift->SUPER::execute_ok(@_);
    my($mm) = $self->req(qw(auth_realm owner))->get_configured_mfa_methods;
    my($totp) = $self->req('Model.UserTOTP');
    # Sanity check
    b_die('wrong totp model')
        unless $totp->get($_UT->REALM_ID_FIELD) eq $self->req('auth_id');
    $totp->delete;
    $self->new_other('MFARecoveryCodeList')->load_all->delete
        unless int(@$mm) > 1;
    $_ULTF->delete_cookie($self->req('cookie'));
    # Need server_redirect for mail task
    return {
        method => 'server_redirect',
        task_id => 'next',
    };
}

sub internal_pre_execute {
    my($self) = @_;
    b_die('MODEL_NOT_FOUND')
        unless $self->new_other('UserTOTP')->unsafe_load;
    return shift->SUPER::internal_pre_execute(@_);
}

1;
