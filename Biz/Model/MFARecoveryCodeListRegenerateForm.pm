# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::MFARecoveryCodeListRegenerateForm;
use strict;
use Bivio::Base 'Model.UserEscalatedAccessBaseForm';

my($_AMRCL) = b_use('Action.MFARecoveryCodeList');

sub execute_ok {
    my($self) = @_;
    # TODO: send email
    unless ($self->ureq('Model.MFARecoveryCodeList')) {
        $_AMRCL->regenerate_list($self->req);
        $self->internal_stay_on_page;
    }
    return;
}

sub internal_pre_execute {
    my($self) = @_;
    b_die('regenerate recovery codes with no MFA methods')
        unless $self->req(qw(auth_realm owner))->get_configured_mfa_methods;
    return shift->SUPER::internal_pre_execute(@_);
}

1;
