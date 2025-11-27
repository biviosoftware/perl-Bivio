# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserEnableTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginTOTPForm';

my($_AMFCL) = b_use('Action.MFARecoveryCodeList');
my($_DT) = b_use('Type.DateTime');
my($_MRCL) = b_use('Model.MFARecoveryCodeList');
my($_RFC6238) = b_use('Biz.RFC6238');
my($_TS) = b_use('Type.TOTPSecret');
my($_UEABF) = b_use('Model.UserEscalatedAccessBaseForm');
my($_UT) = b_use('Model.UserTOTP');
my($_V) = b_use('UI.View');

# TODO: This form assumes that no recovery codes already exist -- once multiple MFA methods are
# implemented, that might not be true. Update as needed.

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(
        totp_secret => $_TS->generate_secret($_UT->get_default_algorithm),
        mfa_recovery_code_array => $self->req($_AMFCL, 'mfa_recovery_code_array'),
    );
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->bypass_challenge;
    shift->SUPER::execute_ok(@_);
    $self->new_other('UserTOTP')->create({
        secret => $self->get('totp_secret'),
        time_step => $_RFC6238->get_time_step($_DT->to_unix($_DT->now), $_UT->get_default_period),
    });
    $_MRCL->create($self->get('mfa_recovery_code_array'));
    $_V->call_main('UserTOTP->enable_mail', $self->req);
    return;
}

sub execute_unwind {
    return shift->delegate_method($_UEABF, @_);
}

sub internal_assert_escalation_challenge {
    return shift->delegate_method($_UEABF, @_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
        $self->field_decl(
            hidden => [
                [qw(totp_secret Line)],
                [qw(mfa_recovery_code_array StringArray)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my($self) = @_;
    b_die('FORBIDDEN')
        if $self->new_other('UserTOTP')->unsafe_load;
    $self->internal_put_field(realm_owner => $self->req(qw(auth_realm owner)));
    return shift->delegate_method($_UEABF, @_);
}

sub validate {
    my($self) = @_;
    $self->internal_put_error(totp_code => 'INVALID_TOTP_CODE')
        unless my $ts = $_UT->is_valid_setup($self->get('totp_code'), $self->get('totp_secret'));
    $self->internal_put_field(totp_time_step => $ts);
    return;
}

1;
