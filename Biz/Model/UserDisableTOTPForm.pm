# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserDisableTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginForm';

my($_DT) = b_use('Type.DateTime');
my($_RFC6238) = b_use('Biz.RFC6238');
my($_RC) = b_use('Model.RecoveryCode');
my($_RCL) = b_use('Model.RecoveryCodeList');
my($_SA) = b_use('Type.StringArray');
my($_T) = b_use('Model.TOTP');
my($_TS) = b_use('Type.TOTPSecret');

sub execute_empty {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_empty(@_);
    $self->internal_put_field(realm_owner => $self->req(qw(auth_realm owner)))
        unless $self->get('realm_owner');
    return @res;
}

sub execute_ok {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_ok(@_);
    return @res
        if $self->in_error;
    $self->req('Model.TOTP')->delete;
    $self->req('Model.RecoveryCodeList')->do_rows(sub {
        my($it) = @_;
        $_RC->load_from_properties({
            user_id => $it->get('RecoveryCode.user_id'),
            code => $it->get('RecoveryCode.code'),
        })->delete;
        return 1;
    });
    $_RC->delete_all;
    return @res;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [{
            name => 'totp_code',
            type => 'Integer',
            constraint => 'NONE',
        }, {
            name => 'recovery_code',
            type => 'RecoveryCode',
            constraint => 'NONE',
        }],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    return 'NOT_FOUND'
        unless $_T->new($self->req)->unsafe_load;
    return 'NOT_FOUND'
        unless $_RCL->new($self->req)->load_all->get_result_set_size;
    return @res;
}

sub internal_validate_recovery_code {
    my($self) = @_;
    return
        if $_RC->new($self->req)->unsafe_load({code => $self->get('recovery_code')});
    $self->internal_put_error(recovery_code => 'INVALID_RECOVERY_CODE');
    return;
}

sub internal_validate_totp_code {
    my($self) = @_;
    $self->internal_put_error(totp_code => 'INVALID_TOTP_CODE')
        unless $self->req('Model.TOTP')->validate_input_code($self->get('totp_code'));
    return;
}

sub validate {
    my($self) = @_;
    my(@res) = shift->SUPER::validate(@_);
    return @res
        if $self->in_error;
    if ($self->get('totp_code')) {
        return $self->internal_validate_totp_code;
    }
    if ($self->get('recovery_code')) {
        return $self->internal_validate_recovery_code;
    }
    $self->internal_put_error(totp_code => 'INVALID_RECOVERY_OPTIONS');
    return;
}

1;
