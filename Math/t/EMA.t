# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
use strict;
use Bivio::Test;
#use Bivio::Math::EMA;
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
	    1 => 1.000000,
	    2 => 1.666667,
	    2 => 1.888889,
	    2 => 1.962963,
	    2 => 1.987654,
	    2 => 1.995885,
	    2 => 1.998628,
	    2 => 1.999543,
	    2 => 1.999848,
	    2 => 1.999949,
	    2 => 1.999983,
	    2 => 1.999994,
	    2 => 1.999998,
	    2 => 1.999999,
	    2 => 2.000000,
	    2 => 2.000000,
	],
    ],
    30 => [
	value => [
	    [] => Bivio::DieCode->DIE,
	],
    ],
    {
	class_name => undef,
	object => 'Bivio::Math::EMA',
    } => [
	new => [
	    -1 => Bivio::DieCode->DIE,
	    0 => Bivio::DieCode->DIE,
	    3.5 => Bivio::DieCode->DIE,
	],
    ],
]);
