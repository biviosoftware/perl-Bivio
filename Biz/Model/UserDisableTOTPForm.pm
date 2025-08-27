# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserDisableTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginForm';

my($_RCT) = b_use('Type.RecoveryCodeType');

sub disable_totp {
    my($self) = @_;
    b_die('models not loaded')
        unless _load($self);
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

sub execute_empty {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_empty(@_);
    $self->internal_put_field(realm_owner => $self->req(qw(auth_realm owner)));
    return @res;
}

sub execute_ok {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_ok(@_);
    $self->disable_totp;
    return @res;
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    return 'NOT_FOUND'
        unless _load($self);
    $self->internal_put_field(require_totp => 1);
    return @res;
}

sub _load {
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

1;
