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
    my($proto, $req) = @_;
    $proto->new($req)->create({
        login_attempt_state => $_S->RESET,
    });
    return;
}

sub unsafe_load_last {
    my($self) = @_;
    return $self->unsafe_load_first('creation_date_time DESC, login_attempt_id DESC');
}

sub update {
    b_die('login attempt record modification not allowed');
}

sub _state {
    my($self, $values) = @_;
    my($state) = $values->{login_attempt_state};
    return $state
        if $state->eq_success || $state->eq_reset;
    b_die('unexpected login_attempt_state=', $state)
        unless $state->eq_failure;
    my($fail_count) = 1;
    $self->new_other('LoginAttempt')->do_iterate(sub {
        my($it) = @_;
        return 0
            if $it->get('login_attempt_state')->eq_success
            || $it->get('login_attempt_state')->eq_reset;
        if (++$fail_count >= $_CFG->{lockout_failure_count}) {
            $state = $_S->LOCKOUT;
            return 0;
        }
        return 1;
    }, 'creation_date_time DESC, login_attempt_id DESC');
    return $state;
}

1;
