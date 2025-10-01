# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Util::UserTOTP;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

my($_DT) = b_use('Type.DateTime');
my($_RFC6238) = b_use('Biz.RFC6238');
my($_T) = b_use('Model.UserTOTP');

sub compute {
    my($self, $secret, $algorithm, $digits, $period) = @_;
    $self->assert_not_general;
    my($m) = $self->model('UserTOTP');
    $m->unsafe_load;
    $secret ||= $m->is_loaded ? $m->get('secret') : ($secret || b_die('no secret'));
    $algorithm ||= $m->is_loaded ? $m->get('algorithm') : $_T->get_default_algorithm;
    $digits ||= $m->is_loaded ? $m->get('digits') : $_T->get_default_digits;
    $period ||= $m->is_loaded ? $m->get('period') : $_T->get_default_period;
    return $_RFC6238->compute(
        $algorithm->get_name,
        $digits,
        $secret,
        $_RFC6238->get_time_step($_DT->to_unix($_DT->now), $period),
    );
}

1;
