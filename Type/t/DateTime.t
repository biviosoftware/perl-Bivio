# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::Type::DateTime;
use Bivio::Type::Date;
use Bivio::Type::Time;
use Bivio::Agent::Request;

# Set the timezone to something specific
Bivio::Agent::Request->get_current_or_new->put(timezone => 120);

# Tests
Bivio::Test->unit([
    'Bivio::Type::DateTime' => [
	from_literal => [
	    [undef] => [undef],
	    '2378497 9' => '2378497 9',
	    '-9' => [undef, Bivio::TypeError->DATE_TIME],
	    'Feb 29 0:0:0 MST 1972' => '2441377 0',
	    'Feb 29 13:13:13 XXX 2000' => '2451604 47593',
	    '1972/2/29 0:0:0' => '2441377 0',
	    '2000/2/29 13:13:13' => '2451604 47593',
	    'Sun Dec 16 13:47:35 GMT 2001' => '2452260 49655',
	    '20000229131313' => '2451604 47593',
	],
	from_local_literal => [
	    [undef] => [undef, undef],
	    ['2378497 9'] => ['2378497 7209'],
	    ['-9'] => [undef, Bivio::TypeError->DATE_TIME],
	    ['Feb 29 0:0:0 MST 1972'] => ['2441377 7200'],
	    ['Feb 29 13:13:13 XXX 2000'] => ['2451604 54793'],
	    ['1972/2/29 0:0:0'] => ['2441377 7200'],
	    ['2000/2/29 13:13:13'] => ['2451604 54793'],
	],
	to_string => [
	    ['2378497 9'] => ['01/01/1800 00:00:09 GMT'],
	    ['2441377 0'] => ['02/29/1972 00:00:00 GMT'],
	    ['2451604 47593'] => ['02/29/2000 13:13:13 GMT'],
	],
	to_local_string => [
	    ['2378497 7209'] => ['01/01/1800 00:00:09'],
	    ['2441377 7200'] => ['02/29/1972 00:00:00'],
	    ['2451604 54793'] => ['02/29/2000 13:13:13'],
	],
	to_parts => [
	    [Bivio::Type::DateTime->get_min]
	    	=> ['0', '0', '0', '1', '1', '1800'],
	    [Bivio::Type::DateTime->get_max]
	    	=> ['59', '59', '23', '31', '12', '2199'],
	    ['2440588 0'] => ['0', '0', '0', '1', '1', '1970'],
	    ['2441377 0'] => ['0', '0', '0', '29', '2', '1972'],
	    ['2451604 47593'] => ['13', '13', '13', '29', '2', '2000'],
	],
	add_days => [
	    ['2440588 0', 1] => ['2440589 0'],
	    ['2440588 0', -1] => ['2440587 0'],
	],
	add_seconds => [
	    ['2440588 0', 1] => ['2440588 1'],
	    ['2440588 0', 86401] => ['2440589 1'],
	    ['2440588 0', -86401] => ['2440586 86399'],
	    ['2440588 0', -1] => ['2440587 86399'],
	],
	{
	    method => 'set_end_of_month',
	    compute_params => sub {
		my($case, $params) = @_;
		my($o) = $case->get('object');
		$case->put(expect => [$o->from_literal_or_die(
			$case->get('expect')->[0])]);
		return [$o->from_literal_or_die($params->[0])];
	    },
	} => [
	    ['12/1/2000 0:0:0'] => ['12/31/2000 0:0:0'],
	    ['2/1/2000 0:0:0'] => ['2/29/2000 0:0:0'],
	    ['2/26/1900 0:0:0'] => ['2/28/1900 0:0:0'],
	    ['2/26/1980 0:32:0'] => ['2/29/1980 0:32:0'],
	],
	from_parts_or_die => [
	    ['13', '13', '13', '29', '2', '2000'] => ['2451604 47593'],
	    ['13', '13', '29', '2', '2000'] => Bivio::DieCode->DIE,
	],
	date_from_parts_or_die => [
	    ['29', '2', '2000'] => ['2451604 79199'],
	    ['32', '2', '2000'] => Bivio::DieCode->DIE,
	],
	delta_days => [
	    ['2452874 05700', '2452874 05700'] => 0,
	    ['2452874 05700', '2452874 27300'] => 0.25,
	    ['2452874 05700', '2452873 48900'] => -0.5,
	    ['2452874 05700', '2452888 06240'] => 14.00625,
	    ['2452874 05700', '2452868 03540'] => -6.025,
	],
	# Just make sure it doesn't blow
	gettimeofday => sub {
	    my($case, $actual) = @_;
	    my($s, $us) = @{$actual->[0]};
	    die($us, ': microseconds greater than 1m')
		unless $us < 1_000_000;
	    return $s <= time ? 1 : 0;
	},
	compare => [
	    ['2452874 05700', '2452874 05700'] => 0,
	    ['2452874 05700', '2452874 27300'] => -1,
	    ['2452874 05700', '2452873 48900'] => 1,
	    [undef, '2452873 48900'] => -1,
	    ['2452873 48900', undef] => 1,
	    [undef, undef] => 0,
	],
	is_equal => [
	    ['2452874 05700', '2452874 05700'] => 1,
	    ['2452874 05700', '2452874 27300'] => 0,
	    ['2452874 05700', '2452873 48900'] => 0,
	    [undef, '2452873 48900'] => 0,
	    ['2452873 48900', undef] => 0,
	    [undef, undef] => 1,
	],
	english_month3 => [
	    1 => 'Jan',
	    12 => 'Dec',
	],
	english_month3_to_int => [
	    Feb => 2,
	    Mar => 3,
	],
    ],
]);
