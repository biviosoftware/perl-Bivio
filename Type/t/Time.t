# $Id$
use strict;
use Bivio::Test;
use Bivio::Type::Time;

# Tests
Bivio::Test->unit([
    'Bivio::Type::Time' => [
#	from_literal => [
#	    ['1:1:1'] => [make_time((1 * 60 + 1) * 60 + 1)],
#	    ['24:0:0'] => [make_time(0)],
#	    ['12:59:0 p.m.'] => [make_time((12 * 60 + 59) * 60 + 0)],
#	    ['12:59:0  a'] => [make_time((0 * 60 + 59) * 60 + 0)],
#	    ['1:0:0  a'] => [make_time((1 * 60 + 0) * 60 + 0)],
#	    ['1:0:1  p'] => [make_time((13 * 60 + 0) * 60 + 1)],
#	],
	from_literal => [
	    [undef] => [undef],
	    ['24:0:0 x'] => [undef, Bivio::TypeError->TIME],
	    ['24:0:0 ax'] => [undef, Bivio::TypeError->TIME],
	    ['24:0:1'] => [undef, Bivio::TypeError->HOUR],
	    ['24:1:0'] => [undef, Bivio::TypeError->HOUR],
	],
    ],
]);
