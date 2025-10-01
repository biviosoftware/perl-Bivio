# Copyright (c) 2025 bivio Software Artisans, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserSecretCode;
use strict;
use Bivio::Base 'Model.RealmBase';

# TODO: rename to UserOneTimeCode?

my($_DT) = b_use('Type.DateTime');
my($_SC) = b_use('Type.SecretCode');

sub REALM_ID_FIELD {
    return 'user_id';
}

sub REALM_ID_FIELD_TYPE {
    return 'User.user_id';
}

sub create {
    my($self, $type, $code) = @_;
    my($values) = ref($type) eq 'HASH' ? $type : {code => $code, type => $type};
    b_die('type required')
        unless $values->{type};
    $values->{code} ||= $_SC->generate_code_for_type($values->{type});
    if ($values->{type}->equals_by_name(qw(password_query password_reset))) {
        $self->new_other('UserSecretCode')->delete_all({type => $values->{type}});
    }
    return $self->SUPER::create({
        %$values,
        expiration_date_time => $_SC->get_expiry_for_type($values->{type}),
        is_used => 0,
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
            is_used => [qw(Boolean NOT_NULL)],
        },
    });
}

sub is_expired {
    my($self) = @_;
    return 0
        unless $self->get('expiration_date_time');
    return $_DT->is_less_than_or_equals($self->get('expiration_date_time'), $_DT->now)
        ? 1 : 0;
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
            if $it->is_expired;
        $found = 1;
        return 0;
    }, $method, {
        is_used => 0,
        %$query,
    });
    return $self
        if $found;
    $self->internal_unload;
    return undef;
}

1;
