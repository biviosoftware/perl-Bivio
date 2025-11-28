# Copyright (c) 2025 bivio, Inc.  All rights reserved.
package Bivio::Type::TOTPTimeStep;
use strict;
use Bivio::Base 'Type.Integer';

my($_DT) = b_use('Type.DateTime');
my($_RFC6238) = b_use('Biz.RFC6238');
my($_TP) = b_use('Type.TOTPPeriod');

Bivio::IO::Config->register(my $_CFG = {
    first_available_date => '11/01/2025 00:00:00',
});

sub get_min {
    return $_RFC6238->get_time_step($_DT->to_unix($_CFG->{first_available_date}), $_TP->get_max);
}

sub get_max {
    return $_RFC6238->get_time_step($_DT->to_unix($_DT->get_max), $_TP->get_min);
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = {
        first_available_date => $_DT->from_literal_or_die($cfg->{first_available_date}),
    };
    return;
}

1;
