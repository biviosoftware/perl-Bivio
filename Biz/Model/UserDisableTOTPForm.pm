# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserDisableTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginTOTPForm';

sub execute_ok {
    my($self) = @_;
    $self->internal_disable_mfa($self);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [{
            name => 'RealmOwner.password',
        }],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->internal_put_field(realm_owner => $self->req(qw(auth_realm owner)));
    $self->internal_load_models;
    return;
}

sub validate {
    my($self) = @_;
    my($ulf) = $self->new_other('UserLoginForm');
    $ulf->validate($self->get_nested(qw(realm_owner name)), $self->get('RealmOwner.password'));
    if ($ulf->in_error) {
        $self->internal_stay_on_page;
        my($e) = $ulf->get_errors;
        $self->internal_put_error('RealmOwner.password' => delete($e->{'RealmOwner.password'}));
        b_die('invalid login=', $self->get('realm_owner'), ' ', $e)
            if %$e;
    }
    return
        if $self->in_error;
    return shift->SUPER::validate(@_);
}

1;
