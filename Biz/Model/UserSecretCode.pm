# Copyright (c) 2025 bivio Software Artisans, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserSecretCode;
use strict;
use Bivio::Base 'Model.RealmBase';

my($_DT) = b_use('Type.DateTime');
my($_MC) = b_use('Type.MnemonicCode');
my($_SC) = b_use('Type.SecretCode');

sub REALM_ID_FIELD {
    return 'user_id';
}

sub REALM_ID_FIELD_TYPE {
    return 'User.user_id';
}

sub create {
    my($self, $type, $code) = @_;
    if ($type->eq_password_query) {
        my($sc) = $self->new_other('UserSecretCode');
        $sc->delete
            if $sc->unsafe_load({type => $type});
    }
    return $self->SUPER::create({
        code => $code || $_SC->generate_code_for_type($type),
        type => $type,
        expiration_date_time => $_SC->get_expiry_for_type($type),
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'user_secret_code_t',
        as_string_fields => [qw(user_secret_code_id type creation_date_time expiration_date_time)],
        columns => {
            user_secret_code_id => [qw(PrimaryId PRIMARY_KEY)],
            code => [qw(SecretLine NOT_NULL)],
            type => [qw(SecretCode NOT_ZERO_ENUM)],
            creation_date_time => [qw(DateTime NOT_NULL)],
            expiration_date_time => [qw(DateTime NONE)],
            is_used => [qw(Boolean NONE)],
        },
    });
}

sub is_valid_for_cookie {
    my($self, $realm_id, $code) = @_;
    return _find($self, $code, 'unauth_iterate_start', {
        user_id => $realm_id,
        type => $_SC->MFA_RECOVERY,
        is_used => 1,
    }) ? 1 : 0;
}

sub set_used {
    return shift->update({is_used => 1});
}

sub unauth_load_by_code_and_type {
    my($self, $user_id, $code, $type) = @_;
    return _find($self, $code, 'unauth_iterate_start', {user_id => $user_id, type => $type});
}

sub unsafe_load_by_code_and_type {
    my($self, $code, $type) = @_;
    return _find($self, $code, 'iterate_start', {type => $type});
}

sub _find {
    my($self, $code, $method, $query) = @_;
    my($found);
    $self->do_iterate(sub {
        my($it) = @_;
        return 1
            unless $it->get('code') eq $_SC->from_literal_for_type($it->get('type'), $code);
        return 1
            if _is_expired($it);
        $found = 1;
        return 0;
    }, $method, $query);
    return $self
        if $found;
    $self->internal_unload;
    return undef;
}

sub _is_expired {
    my($self) = @_;
    return 0
        unless $self->get('expiration_date_time');
    return $_DT->is_less_than_or_equals($self->get('expiration_date_time'), $_DT->now)
        ? 1 : 0;
}

1;
