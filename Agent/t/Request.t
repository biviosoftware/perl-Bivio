# Copyright (c) 2005-2006 bivio Software, Inc.  All rights reserved.
# $Id$
BEGIN {
    use Bivio::IO::Config;
    Bivio::IO::Config->introduce_values({
	'Bivio::IO::ClassLoader' => {
	    delegates => {
		'Bivio::Agent::TaskId' => 'Bivio::Agent::t::Mock::TaskId',
		'Bivio::Auth::RealmType' => 'Bivio::Delegate::RealmType',
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
use Bivio::Agent::t::Mock::Resource;
my($req) = Bivio::Test::Request->get_instance;
my($resource) = Bivio::Agent::t::Mock::Resource->new;
$req->setup_facade();
Bivio::Agent::Task->initialize;
Bivio::Test->new()->unit([
    $req => [
	{
	    method => 'can_user_execute_task',
	    compute_params => sub {
		my(undef, $params) = @_;
		$req->set_user(shift(@$params));
		return $params;
	    },
	} => [
            [qw(guest TEST_MULTI_ROLES1)] => 0,
            [qw(multi_role_user TEST_MULTI_ROLES1)] => 1,
            [qw(multi_role_user TEST_MULTI_ROLES2)] => 1,
	],
	{
	    method => 'unsafe_get_txn_resource',
	    compute_params => sub {
		my(undef, $params) = @_;
		$req->push_txn_resource($params->[0])
		    if @$params;
		return [ref($resource)];
	    },
	} => [
	    [] => [undef],
	    [$resource] => [$resource],
	],
    ],
]);
