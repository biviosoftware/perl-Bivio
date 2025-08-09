# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Util::TOTP;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

my($_DT) = b_use('Type.DateTime');
my($_RFC6238) = b_use('Biz.RFC6238');
my($_T) = b_use('Model.TOTP');

sub compute {
    my($self, $secret, $algorithm, $digits, $period) = @_;
    $self->assert_not_general;
    $algorithm ||= $_T->get_default_algorithm;
    $digits ||= $_T->get_default_digits;
    $period ||= $_T->get_default_period;
    $secret ||= $self->model('TOTP')->load->get('secret');
    return $_RFC6238->compute(
        $algorithm->get_name,
        $digits,
        $secret,
        $_RFC6238->get_time_step($_DT->to_unix($_DT->now), $period),
    );
}

1;
