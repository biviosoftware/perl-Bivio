# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
use strict;
use Bivio::Test;
use POSIX ();
Bivio::Test->new({
    class_name => 'Bivio::Math::EMA',
    check_return => sub {
	my($case, $actual, $expect) = @_;
	# Round actual to 6 decimal places before comparison
	$case->actual_return(
	    [POSIX::floor($actual->[0] * 1000000 + 0.5) / 1000000]);
	return $expect;
    },
})->unit([
    30 => [
    	compute => [
	    1 => 1.000000,
	    1 => 1.000000,
	    5 => 1.258065,
	],
	value => 1.258065,
    ],
    2 => [
    	compute => [
	    13 => 13.000000,
	    14 => 13.666667,
	    14 => 13.888889,
	    14 => 13.962963,
	    14 => 13.987654,
	    14 => 13.995885,
	    14 => 13.998628,
	    14 => 13.999543,
	    14 => 13.999848,
	    14 => 13.999949,
	    14 => 13.999983,
	    14 => 13.999994,
	    14 => 13.999998,
	    14 => 13.999999,
	    14 => 14.000000,
	    14 => 14.000000,
	],
    ],
    30 => [
	value => [
	    [] => Bivio::DieCode->DIE,
	],
    ],
    'Bivio::Math::EMA' => [
	new => [
	    -1 => Bivio::DieCode->DIE,
	    0 => Bivio::DieCode->DIE,
	    3.5 => Bivio::DieCode->DIE,
	],
    ],
]);
