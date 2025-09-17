# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserDisableTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginTOTPForm';

my($_SC) = b_use('Type.SecretCode');

sub execute_ok {
    my($self) = @_;
    $self->internal_disable_totp($self);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        $self->field_decl(
            visible => [
                [qw(RealmOwner.password)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my($self) = @_;
    return 'NOT_FOUND'
        unless _load_models($self);
    $self->internal_put_field(realm_owner => $self->req(qw(auth_realm owner)));
    return;
}

sub validate {
    my($self) = @_;
    my(@res) = shift->SUPER::validate(@_);
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
    return @res;
}

sub _load_models {
    my($self) = @_;
    return 1
        if $self->ureq('Model.UserTOTP') && $self->ureq('Model.MFARecoveryCodeList');
    return 0
        unless $self->new_other('UserTOTP')->unsafe_load;
    return 0
        unless $self->new_other('MFARecoveryCodeList')->load_all({
            type => $_SC->MFA_RECOVERY,
        })->get_result_set_size;
    return 1;
}

1;
