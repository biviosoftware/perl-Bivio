# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::Type::Date;
my($_D) = 'Bivio::Type::Date';

# Tests
Bivio::Test->unit([
    $_D => [
	from_literal => [
	    ['1/1/1850'] => ['2396759 79199'],
	    ['1/2/1800'] => ['2378498 79199'],
	    ['1/1/1900'] => ['2415021 79199'],
	    ['1/1/2000'] => ['2451545 79199'],
	    ['1/1/2100'] => ['2488070 79199'],
	    ['12/31/2199'] => ['2524593 79199'],
	    [undef] => [undef],
	    ['1/1/1970 x'] => [undef, Bivio::TypeError::DATE()],
	],
	to_parts => [
	    [$_D->local_today] =>
	    	[59, 59, 21,
		    (localtime)[3], (localtime)[4] + 1, (localtime)[5] + 1900],
	],
	to_string => [
	    ['2378497 9'] => ['01/01/1800'],
	],
    ],
]);
