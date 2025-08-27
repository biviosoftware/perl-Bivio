# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserEnableTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginForm';

my($_ARC) = b_use('Action.RecoveryCode');
my($_DT) = b_use('Type.DateTime');
my($_RFC6238) = b_use('Biz.RFC6238');
my($_RC) = b_use('Type.RecoveryCode');
my($_RCL) = b_use('Model.RecoveryCodeList');
my($_SA) = b_use('Type.StringArray');
my($_T) = b_use('Model.TOTP');
my($_TS) = b_use('Type.TOTPSecret');

sub execute_empty {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_empty(@_);
    $self->internal_put_field(
        login => $self->req(qw(auth_realm owner_name)),
        totp_secret => $_TS->generate_secret($_T->get_default_algorithm),
        recovery_codes => $self->req($_ARC, 'recovery_code_array'),
    );
    return @res;
}

sub execute_ok {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_ok(@_);
    return @res
        if $self->in_error;
    $_T->new($self->req)->create(
        $self->get('totp_secret'),
        $_RFC6238->get_time_step($_DT->to_unix($_DT->now), $_T->get_default_period),
    );
    $_RCL->create($self->get('recovery_codes'));
    return @res;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [{
            name => 'totp_code',
            type => 'Line',
            constraint => 'NOT_NULL',
        }],
        hidden => [
            'login',
            {
                name => 'recovery_codes',
                type => 'StringArray',
                constraint => 'NOT_NULL',
            },
            {
                name => 'totp_secret',
                type => 'Line',
                constraint => 'NOT_NULL'
            },
        ],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    return 'FORBIDDEN'
        if $_T->new($self->req)->unsafe_load;
    return;
}

sub validate {
    my($self) = @_;
    my(@res) = shift->SUPER::validate(@_);
    return @res
        if $self->in_error;
    $self->internal_put_error(totp_code => 'INVALID_TOTP_CODE')
        unless $_T->validate_setup($self->get('totp_code'), $self->get('totp_secret'));
    return @res;
}

1;
