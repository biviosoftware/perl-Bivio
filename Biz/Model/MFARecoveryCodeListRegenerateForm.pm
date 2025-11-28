# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::MFARecoveryCodeListRegenerateForm;
use strict;
use Bivio::Base 'Model.UserEscalatedAccessBaseForm';

my($_AMRCL) = b_use('Action.MFARecoveryCodeList');
my($_V) = b_use('UI.View');

sub execute_ok {
    my($self) = @_;
    shift->SUPER::execute_ok(@_);
    unless ($self->ureq('Model.MFARecoveryCodeList')) {
        $_AMRCL->regenerate_list($self->req);
        $self->internal_stay_on_page;
        $_V->call_main('UserAuth->mfa_recovery_code_list_regenerate_mail', $self->req);
    }
    return;
}

sub internal_pre_execute {
    my($self) = @_;
    b_die('FORBIDDEN')
        unless $self->req(qw(auth_realm owner))->get_configured_mfa_methods;
    return shift->SUPER::internal_pre_execute(@_);
}

1;
