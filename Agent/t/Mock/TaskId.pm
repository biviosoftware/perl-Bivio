# Copyright (c) 2002-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::t::Mock::TaskId;
use strict;
use Bivio::Base 'Bivio::Delegate::SimpleTaskId';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    my($proto) = @_;
    # Returns the task declarations.
    return $proto->merge_task_info($proto->SUPER::get_delegate_info, [
	[qw(
	    LOGIN
	    500
	    GENERAL
	    ANYBODY
            Action.ClientRedirect->execute_next
            next=SITE_ROOT
	)],
	[qw(
	    REDIRECT_TEST_1
	    501
	    GENERAL
	    ANYBODY
            Action.ClientRedirect->execute_next
            next=REDIRECT_TEST_2
	)],
	[qw(
	    REDIRECT_TEST_2
	    502
	    GENERAL
	    ANY_USER
            FORBIDDEN=SITE_ROOT
	)],
	[qw(
	    REDIRECT_TEST_3
	    503
	    GENERAL
	    ANYBODY
            t1_task=REDIRECT_TEST_1
            t2_task=REDIRECT_TEST_2
	),
	    sub {
		my($req) = @_;
		my($i) = $req->unsafe_get('redirect_test_3') || 0;
		$req->put_durable(redirect_test_3 => ++$i);
		return "t${i}_task";
	    },
	],
	[qw(
	    DEVIANCE_1
	    504
	    GENERAL
	    ANYBODY
	),
	    sub {
		return "no_such_task";
	    },
	],
	[qw(
	    TEST_TRANSIENT
	    505
	    GENERAL
	    TEST_TRANSIENT
            Action.ClientRedirect->execute_next
            next=SITE_ROOT
	)],
	[qw(
	    TEST_MULTI_ROLES1
	    506
	    GENERAL
	    TEST_PERMISSION1
            Action.ClientRedirect->execute_next
            next=SITE_ROOT
	)],
	[qw(
	    TEST_MULTI_ROLES2
	    507
	    GENERAL
	    TEST_PERMISSION2
            Action.ClientRedirect->execute_next
            next=SITE_ROOT
	)],
	[qw(
	    UNSAFE_GET_REDIRECT
	    508
	    GENERAL
	    ANYBODY
            Action.ClientRedirect->execute_next
            next=SITE_ROOT
	    self_task=UNSAFE_GET_REDIRECT
	    login_task=LOGIN
	)],
	[qw(
	    REDIRECT_TEST_4
	    509
	    GENERAL
	    ANYBODY
	    Bivio::Agent::t::Mock::ReturnRedirect
	)],
	[qw(
	    REDIRECT_TEST_5
	    510
	    GENERAL
	    ANYBODY
	), sub {
	    return {
		method => 'server_redirect',
		task_id => 'SITE_ROOT',
		path_info => 'new_path',
	    },
	}],
	[qw(
	    REDIRECT_TEST_6
	    511
	    GENERAL
	    ANYBODY
	), sub {
	    return {
		method => 'server_redirect',
		task_id => 'my_task',
	    },
	},
	   'my_task=REDIRECT_TEST_5',
        ],
    ]);
}

1;
