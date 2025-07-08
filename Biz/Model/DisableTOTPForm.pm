# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::DisableTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginForm';

my($_RCL) = b_use('Model.RecoveryCodeList');
my($_T) = b_use('Model.TOTP');
my($_RFC6238) = b_use('Biz.RFC6238');

sub execute_empty {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_empty(@_);
    $self->internal_put_field(login => $self->req(qw(auth_realm owner_name)));
    return @res;
}

sub execute_ok {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_ok(@_);
    return @res
        if $self->in_error;
    ($self->req('Model.TOTP') || $_T->new($self->req)->load)->delete;
    # probably don't need list model
    ($self->req('Model.RecoveryCodeList') || $_RCL->new($self->req)->load_all)->delete_all;
    return @res;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
            [qw(totp_code RecoveryCode NONE)],
            [qw(recovery_code RecoveryCode NONE)],
        ],
    });
}

sub validate {
    my($self) = @_;
    my(@res) = shift->SUPER::validate(@_);
    unless ($self->get('totp_code') || $self->get('recovery_code')) {
        $self->internal_put_error(
            totp_code => 'EMPTY',
            recovery_code => 'EMPTY',
        );
        return @res;
    }
    if ($self->get('totp_code')) {
        $self->internal_put_error(totp_code => 'INVALID')
            unless $_T->validate_input_code($self->get('totp_code'));
    }
    if ($self->get('recovery_code')) {
        $self->internal_put_error(recovery_code => 'INVALID')
            unless $_RCL->new($self->req)->load_all->find_in_list($self->get('recovery_code'));
    }
    return @res;
}

1;
