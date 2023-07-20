# Copyright (c) 2023 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::LoginAttempt;
use strict;
use Bivio::Base 'Model.RealmBase';

my($_C) = b_use('IO.Config');
my($_S) = b_use('Type.LoginAttemptState');
$_C->register(my $_CFG = {
    lockout_failure_count => $_C->is_test ? 5 : 100,
});

sub create {
    my($self, $values) = @_;
    return $self->SUPER::create({
        %$values,
        login_attempt_state => _state($self, $values),
        ip_address => $self->req->unsafe_get('client_addr'),
    });
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'login_attempt_t',
        as_string_fields => [qw(realm_id creation_date_time login_attempt_state ip_address)],
        columns => {
            login_attempt_id => ['PrimaryId', 'PRIMARY_KEY'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
            login_attempt_state => ['LoginAttemptState', 'NOT_ZERO_ENUM'],
            # Won't have client_addr if created by util
            ip_address => ['IPAddress', 'NONE'],
        },
    });
}

sub reset_failure_count {
    my($self, $realm_id) = @_;
    return $self->create({
        realm_id => $realm_id,
        login_attempt_state => $_S->RESET,
    });
}

sub unauth_load_last_lockout {
    my($self, $realm_id) = @_;
    my($lockout) = 0;
    _iterate($self, $realm_id, sub {
        my($it) = @_;
        $lockout = $it->get('login_attempt_state')->eq_lockout;
        return 0;
    });
    return $lockout;
}

sub update {
    b_die('login attempt record modification not allowed');
}

sub _iterate {
    my($model, $realm_id, $op) = @_;
    $model->do_iterate($op, 'unauth_iterate_start', 'creation_date_time DESC', {
        realm_id => $realm_id,
    });
    return;
}

sub _state {
    my($self, $values) = @_;
    my($state) = $values->{login_attempt_state};
    return $state
        if $state->eq_success || $state->eq_reset;
    b_die('unexpected login_attempt_state=', $state)
        unless $state->eq_failure;
    my($fail_count) = 1;
    _iterate($self->new_other('LoginAttempt'), $values->{realm_id}, sub {
        my($it) = @_;
        return 0
            if $it->get('login_attempt_state')->eq_success
            || $it->get('login_attempt_state')->eq_reset;
        if (++$fail_count >= $_CFG->{lockout_failure_count}) {
            $state = $state->LOCKOUT;
            return 0;
        }
        return 1;
    });
    return $state;
}

1;
