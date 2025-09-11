# Copyright (c) 2025 bivio Software Artisans, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserRecoveryCode;
use strict;
use Bivio::Base 'Model.RealmBase';

my($_DT) = b_use('Type.DateTime');
my($_MC) = b_use('Type.MnemonicCode');
my($_RC) = b_use('Type.RecoveryCode');

sub REALM_ID_FIELD {
    return 'user_id';
}

sub REALM_ID_FIELD_TYPE {
    return 'User.user_id';
}

sub create {
    my($self, $type, $code) = @_;
    if ($type->eq_password_query) {
        my($rc) = $self->new_other('UserRecoveryCode');
        $rc->delete
            if $rc->unsafe_load({type => $type});
    }
    return $self->SUPER::create({
        code => $code || $_RC->generate_code_for_type($type),
        type => $type,
        expiration_date_time => $_RC->get_expiry_for_type($type),
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'user_recovery_code_t',
        as_string_fields => [qw(user_recovery_code_id type creation_date_time expiration_date_time)],
        columns => {
            user_recovery_code_id => [qw(PrimaryId PRIMARY_KEY)],
            code => [qw(SecretLine NOT_NULL)],
            type => [qw(RecoveryCode NOT_ZERO_ENUM)],
            creation_date_time => [qw(DateTime NOT_NULL)],
            expiration_date_time => [qw(DateTime NONE)],
            is_used => [qw(Boolean NONE)],
        },
    });
}

sub is_valid_for_cookie {
    my($self, $realm_id, $code) = @_;
    return 0
        unless _find($self, $code, 'unauth_iterate_start', {
            user_id => $realm_id,
            type => $_RC->MFA_FALLBACK,
        }, 0, 1);
    return 0
        unless $self->get('is_used');
    return 1;
}

sub load_by_code_and_type {
    my($self, $code, $type) = @_;
    return _find($self, $code, 'iterate_start', {type => $type}, 1);
}

sub set_used {
    return shift->update({is_used => 1});
}

sub unauth_load_by_code_and_type {
    my($self, $user_id, $code, $type) = @_;
    return _find($self, $code, 'unauth_iterate_start', {user_id => $user_id, type => $type});
}

sub unauth_load_by_code_and_type_or_die {
    my($self, $user_id, $code, $type) = @_;
    return _find($self, $code, 'unauth_iterate_start', {user_id => $user_id, type => $type}, 1);
}

sub unsafe_load_by_code_and_type {
    my($self, $code, $type) = @_;
    return _find($self, $code, 'iterate_start', {type => $type});
}

sub _find {
    my($self, $code, $method, $query, $do_die, $allow_expired) = @_;
    my($found);
    $self->do_iterate(sub {
        my($it) = @_;
        return 1
            unless $it->get('code') eq $code;
        return 1
            if !$allow_expired && _is_expired($it);
        $found = 1;
        return 0;
    }, $method, $query);
    b_die('recovery code not found')
        if $do_die && !$found;
    return $found ? $self : undef;
}

sub _is_expired {
    my($self) = @_;
    return 0
        unless $self->get('expiration_date_time');
    return $_DT->is_less_than_or_equals($self->get('expiration_date_time'), $_DT->now)
        ? 1 : 0;
}

1;
