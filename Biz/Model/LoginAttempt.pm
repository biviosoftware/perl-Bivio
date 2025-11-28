# Copyright (c) 2023 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::LoginAttempt;
use strict;
use Bivio::Base 'Model.RealmBase';

my($_C) = b_use('IO.Config');
my($_S) = b_use('Type.LoginAttemptState');
$_C->register(my $_CFG = {
    locked_out_failure_count => $_C->is_test ? 5 : 100,
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
    b_die('invalid locked_out_failure_count=', $cfg->{locked_out_failure_count})
        if $cfg->{locked_out_failure_count} < 5 && !$_C->is_test;
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

sub is_state_locked_out {
    return shift->get('login_attempt_state')->eq_locked_out;
}

sub reset_failure_count {
    my($self, $realm_id) = @_;
    return $self->create({
        realm_id => $realm_id,
        login_attempt_state => $_S->RESET,
    });
}

sub unauth_load_last_locked_out {
    my($self, $realm_id) = @_;
    my($locked_out) = 0;
    _iterate($self, $realm_id, sub {
        my($it) = @_;
        $locked_out = $it->is_state_locked_out;
        return 0;
    });
    return $locked_out;
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

sub _maybe_lock_out {
    my($fail_count, $state) = @_;
    return $state->LOCKED_OUT
        if $fail_count >= $_CFG->{locked_out_failure_count};
    return $state;
}

sub _state {
    my($self, $values) = @_;
    my($state) = $values->{login_attempt_state};
    return $state
        if _success_equivalent($state);
    b_die('unexpected login_attempt_state=', $state)
        unless $state->eq_failure;
    # Starting at 1 because this attempt is a failure
    my($fail_count) = 1;
    $state = _maybe_lock_out($fail_count, $state)
        if $_C->is_test;
    return $state
        if $state->eq_locked_out;
    _iterate($self->new_other('LoginAttempt'), $values->{realm_id}, sub {
        my($it) = @_;
        return 0
            if _success_equivalent($it->get('login_attempt_state'));
        $state = _maybe_lock_out(++$fail_count, $state);
        return $state->eq_locked_out ? 0 : 1;
    });
    return $state;
}

sub _success_equivalent {
    return shift->equals_by_name(qw(success reset));
}

1;
