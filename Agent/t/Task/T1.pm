# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Agent::t::Task::T1;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
b_use('Agent.Task')->register(__PACKAGE__);
my($_CALLS) = 0;

sub handle_post_execute_task {
    my($self, $task, $req) = @_;
    b_die($_CALLS, ': must be odd')
	unless $_CALLS % 2;
    $_CALLS++;
    return;
}

sub handle_pre_execute_task {
    my($self, $task, $req) = @_;
    b_die($_CALLS, ': must be even')
	if $_CALLS % 2;
    $_CALLS++;
    return;
}

sub num_calls {
    my($x) = $_CALLS;
    $_CALLS = 0;
    return $x;
}

1;
