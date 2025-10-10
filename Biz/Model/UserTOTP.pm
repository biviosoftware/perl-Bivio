# Copyright (c) 2025 bivio Software Artisans, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserTOTP;
use strict;
use Bivio::Base 'Model.RealmBase';

my($_DT) = b_use('Type.DateTime');
my($_RFC6238) = b_use('Biz.RFC6238');
my($_TA) = b_use('Type.TOTPAlgorithm');
my($_TD) = b_use('Type.TOTPDigits');
my($_TP) = b_use('Type.TOTPPeriod');
my($_TS) = b_use('Type.TOTPSecret');
my($_TST) = b_use('Type.TOTPTimeStepTolerance');

Bivio::IO::Config->register(my $_CFG = {
    default_algorithm => $_TA->SHA1,
    default_digits => 6,
    default_period => 30,
    time_step_tolerance => 1,
});

sub REALM_ID_FIELD {
    return 'user_id';
}

sub REALM_ID_FIELD_TYPE {
    return 'User.user_id';
}

sub SECRET_KEY {
    return 'totp_secret';
}

sub create {
    my($self, $secret, $time_step) = @_;
    return $self->SUPER::create({
        map(($_ => $_CFG->{'default_' . $_}), qw(algorithm digits period)),
        secret => $self->get_field_type('secret')->from_literal_or_die($secret),
        last_time_step => $self->get_field_type('last_time_step')->from_literal_or_die($time_step),
    });
}

sub get_default_algorithm {
    return $_CFG->{default_algorithm};
}

sub get_default_digits {
    return $_CFG->{default_digits};
}

sub get_default_period {
    return $_CFG->{default_period};
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = {
        map(($_->[0] => $_->[1]->from_literal_or_die($cfg->{$_->[0]})), (
            ['default_algorithm', $_TA],
            ['default_digits', $_TD],
            ['default_period', $_TP],
            ['time_step_tolerance', $_TST],
        )),
    };
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'user_totp_t',
        columns => {
            $self->REALM_ID_FIELD => [$self->REALM_ID_FIELD_TYPE, 'PRIMARY_KEY'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
            algorithm => ['TOTPAlgorithm', 'NOT_ZERO_ENUM'],
            digits => ['TOTPDigits', 'NOT_NULL'],
            period => ['TOTPPeriod', 'NOT_NULL'],
            secret => ['TOTPSecret', 'NOT_NULL'],
            last_time_step => ['TOTPTimeStep', 'NONE'],
        },
    });
}

sub is_valid_cookie_code {
    my($proto, $realm_id, $code, $time_step) = @_;
    my($model) = $proto->new->set_ephemeral;
    unless ($model->unauth_load({$proto->REALM_ID_FIELD => $realm_id})) {
        b_warn('validating cookie totp with no totp');
        return 0;
    }
    return _code_valid_for_time_step(
        $code, $model->get(qw(algorithm digits secret)), $time_step);
}

sub is_valid_input_code {
    my($self, $input) = @_;
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

sub is_valid_setup {
    my($proto, $input, $secret) = @_;
    return _input_in_range(
        $input, map($_CFG->{$_}, qw(default_algorithm default_digits default_period)), $secret);
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
            unless _code_valid_for_time_step($input, $algorithm, $digits, $secret, $ts);
        return $ts;
    }
    return undef;
}

sub _code_valid_for_time_step {
    my($code, $algorithm, $digits, $secret, $time_step) = @_;
    return $code eq $_RFC6238->compute($algorithm->get_name, $digits, $secret, $time_step) ? 1 : 0;
}

1;
