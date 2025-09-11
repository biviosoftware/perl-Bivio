# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserEnableTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginTOTPForm';

my($_AMFCL) = b_use('Action.MFAFallbackCodeList');
my($_DT) = b_use('Type.DateTime');
my($_MMFCL) = b_use('Model.MFAFallbackCodeList');
my($_RFC6238) = b_use('Biz.RFC6238');
my($_T) = b_use('Model.UserTOTP');
my($_TS) = b_use('Type.TOTPSecret');

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(
        totp_secret => $_TS->generate_secret($_T->get_default_algorithm),
        fallback_codes => $self->req($_AMFCL, 'fallback_code_array'),
    );
    return;
}

sub execute_ok {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_ok(@_);
    $self->new_other('UserTOTP')->create(
        $self->get('totp_secret'),
        $_RFC6238->get_time_step($_DT->to_unix($_DT->now), $_T->get_default_period),
    );
    $_MMFCL->create($self->get('fallback_codes'));
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
                [qw(fallback_codes StringArray)],
                [qw(totp_secret Line)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my($self) = @_;
    return 'FORBIDDEN'
        if $self->new_other('UserTOTP')->unsafe_load;
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
