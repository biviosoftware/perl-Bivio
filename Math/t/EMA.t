#!perl -w
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::Math::EMA;
use POSIX ();
Bivio::Test->new({
    result_ok => sub {
	my($object, $method, $params, $expect, $actual) = @_;
	# Round to 6 decimal places
	return POSIX::floor($actual->[0] * 1000000 + 0.5) / 1000000
	    == $expect->[0];
    },
})->unit([
    Bivio::Math::EMA->new(30) => [
    	compute => [
	    [1] => [1.000000],
	    [1] => [1.000000],
	    [5] => [1.258065],
	],
    ],
    Bivio::Math::EMA->new(2) => [
    	compute => [
	    [1] => [1.000000],
	    [2] => [1.666667],
	    [2] => [1.888889],
	    [2] => [1.962963],
	    [2] => [1.987654],
	    [2] => [1.995885],
	    [2] => [1.998628],
	    [2] => [1.999543],
	    [2] => [1.999848],
	    [2] => [1.999949],
	    [2] => [1.999983],
	    [2] => [1.999994],
	    [2] => [1.999998],
	    [2] => [1.999999],
	    [2] => [2.000000],
	    [2] => [2.000000],
	],
    ],
]);
