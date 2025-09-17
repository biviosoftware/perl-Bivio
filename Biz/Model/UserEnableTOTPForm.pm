# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserEnableTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginTOTPForm';

my($_AMFCL) = b_use('Action.MFARecoveryCodeList');
my($_DT) = b_use('Type.DateTime');
my($_MMFCL) = b_use('Model.MFARecoveryCodeList');
my($_RFC6238) = b_use('Biz.RFC6238');
my($_TS) = b_use('Type.TOTPSecret');
my($_UT) = b_use('Model.UserTOTP');

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(
        totp_secret => $_TS->generate_secret($_UT->get_default_algorithm),
        recovery_codes => $self->req($_AMFCL, 'recovery_code_array'),
    );
    return;
}

sub execute_ok {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_ok(@_);
    $self->new_other('UserTOTP')->create(
        $self->get('totp_secret'),
        $_RFC6238->get_time_step($_DT->to_unix($_DT->now), $_UT->get_default_period),
    );
    $_MMFCL->create($self->get('recovery_codes'));
    return @res;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        $self->field_decl(
            visible => [
                [qw(RealmOwner.password)],
            ],
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
        if $self->new_other('UserTOTP')->unsafe_load;
    $self->internal_put_field(realm_owner => $self->req(qw(auth_realm owner)));
    return;
}

sub validate {
    my($self) = @_;
    # TODO: i don't love doing the password validation this way
    my($ulf) = $self->new_other('UserLoginForm');
    $ulf->validate($self->get_nested(qw(realm_owner name)), $self->get('RealmOwner.password'));
    if ($ulf->in_error) {
        $self->internal_stay_on_page;
        my($e) = $ulf->get_errors;
        $self->internal_put_error('RealmOwner.password' => delete($e->{'RealmOwner.password'}));
        b_die('invalid login=', $self->get('realm_owner'), ' ', $e)
            if %$e;
    }
    $self->internal_put_error(totp_code => 'INVALID_TOTP_CODE')
        unless my $ts = $_UT->is_valid_setup($self->get('totp_code'), $self->get('totp_secret'));
    $self->internal_put_field(totp_time_step => $ts);
    return;
}

1;
