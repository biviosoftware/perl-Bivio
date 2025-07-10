# Copyright (c) 2025 bivio Software Artisans, Inc.  All Rights Reserved.
package Bivio::Biz::Model::RecoveryCode;
use strict;
use Bivio::Base 'Model.RealmBase';

my($_RCL) = b_use('Model.RecoveryCodeList');

sub REALM_ID_FIELD {
    return 'user_id';
}

sub REALM_ID_FIELD_TYPE {
    return 'User.user_id';
}

sub create {
    my($self, $code) = @_;
    return $self->SUPER::create({
        code => $code,
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'recovery_code_t',
        columns => {
            $self->REALM_ID_FIELD => [$self->REALM_ID_FIELD_TYPE, 'PRIMARY_KEY'],
            code => ['RecoveryCode', 'PRIMARY_KEY'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
        },
    });
}

sub validate {
    my($self, $code) = @_;
    my($found) = $_RCL->new($self->req)->load_all->is_in_list($code);
    return 0
        unless $found;
    # TODO: keep the other codes, or delete all?
    $found->delete;
    return 1;
}

1;
