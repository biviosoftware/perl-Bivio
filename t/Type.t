# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
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
    ],
]);
