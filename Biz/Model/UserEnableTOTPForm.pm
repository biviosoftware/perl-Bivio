# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserEnableTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginTOTPForm';

my($_ARC) = b_use('Action.RecoveryCode');
my($_DT) = b_use('Type.DateTime');
my($_RFC6238) = b_use('Biz.RFC6238');
my($_RCL) = b_use('Model.RecoveryCodeList');
my($_T) = b_use('Model.TOTP');
my($_TS) = b_use('Type.TOTPSecret');

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(
        totp_secret => $_TS->generate_secret($_T->get_default_algorithm),
        recovery_codes => $self->req($_ARC, 'recovery_code_array'),
    );
    return;
}

sub execute_ok {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_ok(@_);
    $self->new_other('TOTP')->create(
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
        $self->field_decl(
            visible => [{
                name => 'RealmOwner.password',
            }],
            hidden => [
                [qw(recovery_codes StringArray)],
                [qw(totp_secret Line)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my($self) = @_;
    return 'FORBIDDEN'
        if $self->new_other('TOTP')->unsafe_load;
    $self->internal_put_field(realm_owner => $self->req(qw(auth_realm owner)));
    return;
}

sub internal_validate_realm_owner {
    return;
}

sub validate {
    my($self) = @_;
    $self->internal_put_error('RealmOwner.password' => 'PASSWORD_MISMATCH')
        unless $self->get('realm_owner')->get_field_type('password')->is_equal(
            $self->get_nested(qw(realm_owner password)),
            $self->get('RealmOwner.password'),
        );
    $self->internal_put_error(totp_code => 'INVALID_TOTP_CODE')
        unless my $ts = $_T->is_valid_setup($self->get('totp_code'), $self->get('totp_secret'));
    $self->internal_put_field(totp_time_step => $ts);
    return;
}

1;
