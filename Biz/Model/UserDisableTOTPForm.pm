# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserDisableTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginForm';

my($_RC) = b_use('Model.RecoveryCode');
my($_RCL) = b_use('Model.RecoveryCodeList');
my($_RCT) = b_use('Type.RecoveryCodeType');
my($_T) = b_use('Model.TOTP');

sub disable_totp {
    my($self) = @_;
    $self->req('Model.TOTP')->delete;
    $self->req('Model.RecoveryCodeList')->do_rows(sub {
        my($it) = @_;
        $_RC->new($self->req)->load({
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
    $self->disable_totp
        unless $self->unsafe_get('totp_disabled');
    return @res;
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    return 'NOT_FOUND'
        unless $_T->new($self->req)->unsafe_load;
    return 'NOT_FOUND'
        unless $_RCL->new($self->req)->load_all({type => $_RCT->TOTP_LOST})->get_result_set_size;
    $self->internal_put_field(require_totp => 1);
    return @res;
}

1;
