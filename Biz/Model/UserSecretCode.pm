# Copyright (c) 2025 bivio Software Artisans, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserSecretCode;
use strict;
use Bivio::Base 'Model.RealmBase';

# TODO: "UserAccessCode"?

my($_DT) = b_use('Type.DateTime');
my($_C) = b_use('Type.SecretCode');
my($_S) = b_use('Type.SecretCodeStatus');
my($_STARTING_STATUSES) = {
    LOGIN_CHALLENGE => ['PENDING'],
    ESCALATION_CHALLENGE => ['PENDING'],
    MFA_RECOVERY => ['ACTIVE'],
    PASSWORD_QUERY => ['ACTIVE'],
};
my($_STATUS_TRANSITIONS) = {
    LOGIN_CHALLENGE => {PENDING => ['PASSED']},
    ESCALATION_CHALLENGE => {PENDING => ['PASSED']},
    MFA_RECOVERY => {ACTIVE => ['ARCHIVED']},
    PASSWORD_QUERY => {ACTIVE => ['USED']},
};

sub REALM_ID_FIELD {
    return 'user_id';
}

sub REALM_ID_FIELD_TYPE {
    return 'User.user_id';
}

sub create {
    my($self, $values) = @_;
    b_die('type required')
        unless $values->{type};
    b_die('status required')
        unless $values->{status};
    b_die('invalid status')
        unless grep(
            $values->{status}->equals_by_name($_),
            @{$_STARTING_STATUSES->{$values->{type}->get_name}},
        );
    $values->{code} ||= $values->{type}->generate_code_for_type;
    if ($values->{type}->equals_by_name(qw(
        login_challenge
        escalation_challenge
        password_query
    ))) {
        # Note this means that users can only have one challenge in progress at a time.
        $self->new_other('UserSecretCode')->delete_all({type => $values->{type}});
    }
    return $self->SUPER::create({
        %$values,
        expiration_date_time => $values->{type}->get_expiry_for_type,
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'user_secret_code_t',
        as_string_fields => [qw(user_secret_code_id user_id creation_date_time expiration_date_time type status)],
        columns => {
            user_secret_code_id => [qw(PrimaryId PRIMARY_KEY)],
            creation_date_time => [qw(DateTime NOT_NULL)],
            modified_date_time => [qw(DateTime NOT_NULL)],
            expiration_date_time => [qw(DateTime NONE)],
            code => [qw(SecretLine NOT_NULL)],
            type => [qw(SecretCode NOT_ZERO_ENUM)],
            status => [qw(SecretCodeStatus NOT_ZERO_ENUM)],
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

sub is_valid_cookie_code {
    my($proto, $realm_id, $code) = @_;
    my($model) = $proto->new->set_ephemeral;
    return _find($model, $code, 'unauth_iterate_start', {
        user_id => $realm_id,
        type => $_C->MFA_RECOVERY,
        status => $_S->ARCHIVED,
    }) ? 1 : 0;
}

sub update {
    my($self, $values) = _validate_update(@_);
    return $self->SUPER::update($values);
}

sub unauth_load_by_code {
    my($self, $code, $query) = @_;
    return _find($self, $code, 'unauth_iterate_start', $query);
}

sub unsafe_load_by_code {
    my($self, $code, $query) = @_;
    return _find($self, $code, 'iterate_start', $query);
}

sub _validate_update {
    my($self, $values) = @_;
    if ($values->{status}) {
        b_die(
            $self,
            ' type=', $self->get('type'),
            ' status=', $self->get('status'),
            ' update to=', $values->{status}, ' not allowed',
        ) unless grep(
            $_ eq $values->{status}->get_name,
            @{$_STATUS_TRANSITIONS->{$self->get('type')->get_name}{$self->get('status')->get_name}},
        );
    }
    return ($self, $values);
}

sub _find {
    my($self, $code, $method, $query) = @_;
    foreach my $f ('type', 'status', $method =~ /unauth/ ? 'user_id' : ()) {
        b_die($f . ' required')
            unless $query->{$f};
    }
    my($found);
    $self->do_iterate(sub {
        my($it) = @_;
        return 1
            unless $it->get('code') eq $code;
        return 1
            if $it->is_expired;
        $found = 1;
        return 0;
    }, $method, $query);
    return $self
        if $found;
    $self->internal_unload;
    return undef;
}

1;
