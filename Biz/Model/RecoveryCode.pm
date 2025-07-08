# Copyright (c) 2025 bivio Software Artisans, Inc.  All Rights Reserved.
package Bivio::Biz::Model::RecoveryCode;
use strict;
use Bivio::Base 'Biz.PropertyModel';

# TODO: UserRecoveryCode?

my($_RCL) = b_use('Model.RecoveryCodeList');

sub create {
    my($self, $code) = @_;
    return $self->SUPER::create({
        user_id => $self->req('auth_user_id'),
        code => $code,
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'recovery_code_t',
        columns => {
            user_id => ['User.user_id', 'PRIMARY_KEY'],
            code => ['RecoveryCode', 'PRIMARY_KEY'],
        },
        auth_id => 'user_id',
    });
}

sub validate {
    my($self, $code) = @_;
    my($found) = $_RCL->is_in_list($code);
    return 0
        unless $found;
    # TODO: keep the other codes, or delete all?
    $found->delete;
    return 1;
}

1;
