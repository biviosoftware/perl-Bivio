# Copyright (c) 2025 bivio Software Artisans, Inc.  All Rights Reserved.
package Bivio::Biz::Model::TOTP;
use strict;
use Bivio::Base 'Biz.PropertyModel';
use MIME::Base32 ();

my($_DT) = b_use('Type.DateTime');
my($_RFC6238) = b_use('Biz.RFC6238');
my($_TA) = b_use('Type.TOTPAlgorithm');
my($_TS) = b_use('Type.TOTPSecret');

Bivio::IO::Config->register(my $_CFG = {
    algorithm => $_TA->SHA1,
    digits => 6,
    period => 30,
    time_step_tolerance => 1,
});

sub create {
    my($self, $secret, $time_step) = @_;
    return $self->SUPER::create({
        user_id => $self->req('auth_user_id'),
        map(($_ => $_CFG->{$_}), qw(algorithm digits period)),
        secret => $secret,
        last_time_step => $time_step,
    });
}

sub handle_config {
    my(undef, $cfg) = @_;
    b_die('unsupported digits')
        unless $cfg->{digits} == 6 || $cfg->{digits} == 8;
    b_die('unsupported period')
        unless $cfg->{period} >= 30 && $cfg->{period} <= 90;
    b_die('unsupported time_step_tolerance')
        unless $cfg->{time_step_tolerance} <= 3;
    $cfg->{algorithm} = $_TA->from_any($cfg->{algorithm});
    $_CFG = $cfg;
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'totp_t',
        columns => {
            user_id => ['User.user_id', 'PRIMARY_KEY'],
            algorithm => ['TOTPAlgorithm', 'NOT_ZERO_ENUM'],
            digits => ['Integer', 'NOT_NULL'],
            period => ['Integer', 'NOT_NULL'],
            secret => ['TOTPSecret', 'NOT_NULL'],
            last_time_step => ['Integer', 'NONE'],
        },
        auth_id => 'user_id',
    });
}

sub validate_login {
    my($self, $input, $auth_user) = @_;
    $self->unauth_load_or_die({user_id => $auth_user->get('realm_id')});
    my($time_step) = _input_in_range($input, $self->get(qw(algorithm digits period secret)));
    return 0
        unless $time_step;
    if ($time_step == ($self->get('last_time_step') // -1)) {
        b_warn('TOTP code reuse disallowed');
        return 0;
    }
    $self->update({last_time_step => $time_step});
    return 1;
}

sub validate_setup {
    my($proto, $input, $secret) = @_;
    return _input_in_range($input, $_CFG->{algorithm}, $_CFG->{digits}, $_CFG->{period}, $secret);
}

sub _input_in_range {
    my($input, $algorithm, $digits, $period, $secret) = @_;
    my($now_ts) = $_RFC6238->get_time_step($_DT->to_unix($_DT->now), $period);
    foreach my $ts (
        # Test time step for now first as it will most often be the valid one
        $now_ts,
        map($now_ts + $_, grep($_ != 0, -$_CFG->{time_step_tolerance} .. $_CFG->{time_step_tolerance}))
    ) {
        next
            unless _input_valid_for_time_step($input, $algorithm, $digits, $secret, $ts);
        return $ts;
    }
    return undef;
}

sub _input_valid_for_time_step {
    my($input, $algorithm, $digits, $secret, $time_step) = @_;
    return $input eq $_RFC6238->compute($algorithm->get_name, $digits, $secret, $time_step);
}

1;
