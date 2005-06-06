# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
BEGIN {
    use Bivio::IO::Config;
    Bivio::IO::Config->introduce_values({
	'Bivio::IO::ClassLoader' => {
	    delegates => {
		'Bivio::Agent::TaskId' => 'Bivio::Agent::t::Mock::TaskId',
		'Bivio::Auth::Permission'
		    => 'Bivio::Agent::t::Mock::Permission',
	    },
	    maps => {
		Facade => ['Bivio::Agent::t::Mock::Facade'],
	    },
	},
	'Bivio::UI::Facade' => {
	    default => 'Mock',
	},
    });
}
use Bivio::Test;
use Bivio::Test::Request;
use Bivio::Agent::Task;
my($req) = Bivio::Test::Request->get_instance;
$req->setup_facade();
Bivio::Agent::Task->initialize;
Bivio::Test->new()->unit([
    sub {
	$req->set_user('guest');
	return $req;
    },
        => [
	can_user_execute_task => [
            ['TEST_MULTI_ROLES1'] => [0],
	],
    ],
    sub {
	$req->set_user('multi_role_user');
	return $req;
    },
        => [
	can_user_execute_task => [
            ['TEST_MULTI_ROLES1'] => [1],
	],
    ],
    sub {
	$req->set_user('multi_role_user');
	return $req;
    },
        => [
	can_user_execute_task => [
            ['TEST_MULTI_ROLES2'] => [1],
	],
    ],
]);
