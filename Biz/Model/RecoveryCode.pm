# Copyright (c) 2025 bivio Software Artisans, Inc.  All Rights Reserved.
package Bivio::Biz::Model::RecoveryCode;
use strict;
use Bivio::Base 'Model.RealmBase';

# TODO: rename to UserRecoveryCode?

my($_DT) = b_use('Type.DateTime');
my($_RCT) = b_use('Type.RecoveryCodeType');

sub REALM_ID_FIELD {
    return 'user_id';
}

sub REALM_ID_FIELD_TYPE {
    return 'User.user_id';
}

sub create {
    my($self, $code, $type, $expiry) = @_;
    # $self->new_other('RecoveryCodeList')->delete_all_expired;
    if ($type && $type->eq_password_query) {
        my($rc) = $self->new($self->req);
        # $rc->delete
        #     if $rc->unsafe_load({type => $type});
        $rc->update(expiration_date_time => $_DT->now);
    }
    return $self->SUPER::create({
        code => $code,
        type => $type || $_RCT->TOTP_LOST,
        expiration_date_time => $expiry,
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'recovery_code_t',
        as_string_fields => [qw(recovery_code_id type creation_date_time expiration_date_time)],
        columns => {
            recovery_code_id => ['PrimaryId', 'PRIMARY_KEY'],
            code => ['RecoveryCode', 'NOT_NULL'],
            type => ['RecoveryCodeType', 'NOT_ZERO_ENUM'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
            expiration_date_time => ['DateTime', 'NONE'],
        },
    });
}

sub is_expired {
    my($self) = @_;
    return $_DT->is_less_than($self->get('expiration_date_time'), $_DT->now) ? 1 : 0;
}

sub load_by_code_and_type {
    my($self, $code, $type) = @_;
    return _iterate($self, 1, $code, 'iterate_start', {type => $type});
}

sub set_expired {
    my($self) = @_;
    $self->update({expiration_date_time => $_DT->now});
    return;
}

sub unauth_load_by_code_and_type {
    my($self, $user_id, $code, $type) = @_;
    return _iterate($self, 0, $code, 'unauth_iterate_start', {user_id => $user_id, type => $type});
}

sub unauth_load_by_code_and_type_or_die {
    my($self, $user_id, $code, $type) = @_;
    return _iterate($self, 1, $code, 'unauth_iterate_start', {user_id => $user_id, type => $type});
}

sub unsafe_load_by_code_and_type {
    my($self, $code, $type) = @_;
    return _iterate($self, 0, $code, 'iterate_start', {type => $type});
}

sub validate_for_cookie {
    my($self) = @_;
    return 0
        unless $self->is_expired;
    # Recovery codes are force-expired when used to log in; thus cookie codes are only valid if expired.
    return 1;
}

sub _iterate {
    my($self, $do_die, $code, $method, $query) = @_;
    my($found);
    $self->do_iterate(sub {
        my($it) = @_;
        return 1
            unless $it->get('code') eq $code;
        $found = 1;
        return 0;
    }, $method, $query);
    if ($do_die) {
        b_die('recovery code not found')
            unless $found;
        b_die('expired recovery code=', $self)
            if $self->is_expired;
    }
    return $found ? $self : undef;
}

1;
