# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::Type::Time;

# Tests
Bivio::Test->unit([
    'Bivio::Type::Time' => [
	from_datetime => [
	    ['2453740 44700'] => ['2378497 44700'],
	],
	from_literal => [
	    ['1:1:1'] => ['2378497 3661'],
	    ['24:0:0'] => ['2378497 0'],
	    ['12:59:0 p.m.'] => ['2378497 46740'],
	    ['12:59:0  a'] => ['2378497 3540'],
	    ['1:0:0  a'] => ['2378497 3600'],
	    ['1:0:1  p'] => ['2378497 46801'],
	    [undef] => [undef],
	    ['24:0:0 x'] => [undef, Bivio::TypeError->TIME],
	    ['24:0:0 ax'] => [undef, Bivio::TypeError->TIME],
	    ['24:0:1'] => [undef, Bivio::TypeError->HOUR],
	    ['24:1:0'] => [undef, Bivio::TypeError->HOUR],
	],
    ],
]);
