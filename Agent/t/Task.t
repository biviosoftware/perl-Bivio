# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
BEGIN {
    use Bivio::IO::Config;
    Bivio::IO::Config->introduce_values({
	'Bivio::IO::ClassLoader' => {
	    delegates => {
		'Bivio::Agent::TaskId' => 'Bivio::Agent::t::Task::TaskId',
	    },
	    maps => {
		Facade => ['Bivio::Agent::t::Task::Facade'],
	    },
	},
	'Bivio::UI::Facade' => {
	    default => 'Task',
	},
    });
}
use Bivio::Test;
use Bivio::Test::Request;
use Bivio::Agent::Task;
my($_req) = Bivio::Test::Request->get_instance;
Bivio::Agent::Task->initialize;
$_req->setup_facade->ignore_redirects(0);
Bivio::Test->new({
    create_object => sub {
	my($case, $object) = @_;
	return Bivio::Agent::Task->get_by_id($object->[0]);
    },
    compute_params => sub {
	my($case, $params) = @_;
	$case->put(expected_task => $params->[0]);
	return [$_req];
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
		$next => Bivio::DieCode->SERVER_REDIRECT_TASK,
	    ],
	];
    }
    [qw(SHELL_UTIL SITE_ROOT)],
    [qw(REDIRECT_TEST_1 REDIRECT_TEST_2)],
#TODO: this no longer works - it returns a FORBIDDEN diecode
#    [qw(REDIRECT_TEST_2 LOGIN)],
    [qw(REDIRECT_TEST_3 REDIRECT_TEST_1)],
    [qw(REDIRECT_TEST_3 REDIRECT_TEST_2)]),
    DEVIANCE_1 => [
	execute => [
#TODO: Undeprecate!
#	    [] => Bivio::DieCode->DIE,
	    [] => [],
	],
    ],
]);
