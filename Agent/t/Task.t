# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
BEGIN {
    use Bivio::IO::Config;
    Bivio::IO::Config->introduce_values({
	'Bivio::IO::ClassLoader' => {
	    delegates => {
		'Bivio::Agent::TaskId' => 'Bivio::Agent::t::Mock::TaskId',
		'Bivio::Auth::RealmType' => 'Bivio::Delegate::RealmType',
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
use Bivio::Test::Unit;
use Bivio::Test::Request;
use Bivio::Agent::Task;
my($req) = Bivio::Test::Request->get_instance;
Bivio::Agent::Task->initialize;
$req->setup_facade->ignore_redirects(0);
Bivio::Test->new({
    create_object => sub {
	my($case, $object) = @_;
	return Bivio::Agent::Task->get_by_id($object->[0]);
    },
    compute_params => sub {
	my($case, $params, $method) = @_;
	return $params
	    unless $method eq 'execute';
	$case->put(expected_task => $params->[0]);
	$req->clear_nondurable_state;
	return [$req];
    },
    check_return => sub {
	my($case, $actual, $expect) = @_;
	return $expect
	    unless $case->get('method') eq 'execute';
	my($t) = $req->get('task_id');
	return 0
	    unless $t;
	Bivio::Test::Unit->builtin_assert_equals(
	    $case->get('expected_task'), $t->get_name);
	return 1;
    },
})->unit([
    (map {
	my($this, $next) = @$_;
	$this => [
	    execute => [
		$next => $next eq 'FORBIDDEN' ? Bivio::DieCode->FORBIDDEN
		    : [],
	    ],
	];
    }
	[qw(TEST_ITEMS_1 SHELL_UTIL)],
	[qw(TEST_ITEMS_2 LOGIN)],
 	[qw(SHELL_UTIL SITE_ROOT)],
 	[qw(REDIRECT_TEST_1 REDIRECT_TEST_2)],
 	[qw(REDIRECT_TEST_3 REDIRECT_TEST_1)],
 	[qw(REDIRECT_TEST_3 REDIRECT_TEST_2)],
 	[qw(REDIRECT_TEST_4 REDIRECT_TEST_2)],
 	[qw(REDIRECT_TEST_2 FORBIDDEN)],
 	[qw(REDIRECT_TEST_5 SITE_ROOT)],
 	[qw(REDIRECT_TEST_6 REDIRECT_TEST_5)],
 	[qw(TEST_TRANSIENT SITE_ROOT)],
    ),
    TEST_TRANSIENT => [
 	execute => [
 	    sub {
 		$req->put(is_test => 0);
 		return [$req];
 	    } => Bivio::DieCode->FORBIDDEN,
 	],
	put_attr_for_test => [
	    [
		form_model => 'Bivio::Biz::Model::UserLoginForm',
		next => Bivio::Agent::TaskId->REDIRECT_TEST_5,
	    ] => undef,
	],
	get => [
	    form_model => 'Bivio::Biz::Model::UserLoginForm',
	    next => [Bivio::Agent::TaskId->REDIRECT_TEST_5],
	],
	{
	    method => 'dep_get_attr',
	    comparator => 'nested_contains',
	} => [
	    next => [{
		task_id => Bivio::Agent::TaskId->REDIRECT_TEST_5,
	    }],
	],
	get_attr_as_id => [
	    next => [Bivio::Agent::TaskId->REDIRECT_TEST_5],
	],
    ],
    DEVIANCE_1 => [
 	execute => => Bivio::DieCode->DIE,
    ],
    UNSAFE_GET_REDIRECT => [
 	{
 	    method => 'unsafe_get_redirect',
 	    compute_params => sub {[$_[1]->[0], $req]},
 	    compute_return => sub {[
		$_[1]->[0] && $_[1]->[0]->{task_id}->get_name,
	    ]},
         } => [
 	    next => 'SITE_ROOT',
 	    login_task => 'LOGIN',
 	    not_a_task => [undef],
 	],
    ],
]);
