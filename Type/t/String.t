# Copyright (c) 2004 bivio Software Artisans, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
Bivio::Test->new('Bivio::Type::String')->unit([
    Bivio::Type::String => [
	compare => [
	    [undef, undef] => 0,
	    [undef, ''] => 0,
	    ['', undef] => 0,
	    ['', 'x'] => -1,
	    ['x', ''] => 1,
	],
    ],
]);
