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
Bivio::Agent::Task->initialize;
$req->setup_facade->ignore_redirects(0);
Bivio::Test->new({
    create_object => sub {
	my($case, $object) = @_;
	return Bivio::Agent::Task->get_by_id($object->[0]);
    },
    compute_params => sub {
	my($case, $params) = @_;
	$case->put(expected_task => $params->[0]);
	return [$req];
    },
    check_die_code => sub {
	my($case, $die, $expect) = @_;
	return $expect
	    unless $expect->equals_by_name('SERVER_REDIRECT_TASK');
	my($t) = $die->get('attrs')->{task_id};
	return 0 unless $t;
	# The $t produces a better error message
	return $t->equals_by_name($case->get('expected_task')) ? 1 : $t;
    },
})->unit([
    (map {
	my($this, $next) = @$_;
	$this => [
	    execute => [
		$next => $next eq 'FORBIDDEN' ? Bivio::DieCode->FORBIDDEN
		    : Bivio::DieCode->SERVER_REDIRECT_TASK,
	    ],
	];
    }
	[qw(SHELL_UTIL SITE_ROOT)],
	[qw(REDIRECT_TEST_1 REDIRECT_TEST_2)],
#TODO: this no longer works - it returns a FORBIDDEN diecode
	[qw(REDIRECT_TEST_3 REDIRECT_TEST_1)],
	[qw(REDIRECT_TEST_3 REDIRECT_TEST_2)],
	[qw(REDIRECT_TEST_2 FORBIDDEN)],
	[qw(TEST_TRANSIENT SITE_ROOT)],
    ),
    TEST_TRANSIENT => [
	execute => [
	    sub {
		$req->put(is_test => 0);
		return [$req];
	    } => Bivio::DieCode->FORBIDDEN,
	],
    ],
    DEVIANCE_1 => [
	execute => [
#TODO: Undeprecate!
#	    [] => Bivio::DieCode->DIE,
	    [] => [],
	],
    ],
]);
