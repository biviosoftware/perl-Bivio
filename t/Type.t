# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
use strict;
use Bivio::Test;
Bivio::Test->new('Bivio::Type')->unit([
    'Bivio::Type' => [
	is_equal => [
	    [undef, undef] => 1,
	    [undef, ''] => 0,
	    ['', undef] => 0,
	    ['', 'x'] => 0,
	    ['x', ''] => 0,
	    ['', ''] => 1,
	    ['x', 'x'] => 1,
	],
	compare => [
	    [undef, undef] => 0,
	    [undef, ''] => -1,
	    ['', undef] => 1,
	    ['', 'x'] => -1,
	    ['x', ''] => 1,
	    ['', ''] => 0,
	    ['x', 'x'] => 0,
	],
	is_specified_literal => [
	    [undef] => 0,
	    '' => 1,
	],
	# See String.bunit for more tests
    ],
]);
