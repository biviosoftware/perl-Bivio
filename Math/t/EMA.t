# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
use strict;
use Bivio::Test;
use POSIX ();
Bivio::Test->new({
    class_name => 'Bivio::Math::EMA',
    check_return => sub {
	my($case, $actual, $expect) = @_;
	# Round actual before comparison with expect
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
	    8 => 8.000000,
	    9 => 8.666667,
	    9 => 8.888889,
	    9 => 8.962963,
	    9 => 8.987654,
	    9 => 8.995885,
	    9 => 8.998628,
	    9 => 8.999543,
	    9 => 8.999848,
	    9 => 8.999949,
	    9 => 8.999983,
	    9 => 8.999994,
	    9 => 8.999998,
	    9 => 8.999999,
	    9 => 9.000000,
	    9 => 9.000000,
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
