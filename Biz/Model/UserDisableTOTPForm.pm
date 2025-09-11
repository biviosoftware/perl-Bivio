# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserDisableTOTPForm;
use strict;
use Bivio::Base 'Model.UserLoginTOTPForm';

my($_RCT) = b_use('Type.RecoveryCode');

sub execute_ok {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_ok(@_);
    $self->internal_disable_totp;
    return @res;
}

sub internal_pre_execute {
    my($self) = @_;
    return 'NOT_FOUND'
        unless $self->internal_load_models($self);
    $self->internal_put_field(realm_owner => $self->req(qw(auth_realm owner)));
    return;
}

sub internal_validate_realm_owner {
    my($self) = @_;
    b_die('NOT_FOUND')
        unless $self->get('realm_owner')->require_totp;
    return;
}

1;
