# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
use strict;
use Bivio::Test;
Bivio::Test->new('Bivio::Math::EMA')->unit([
    4 => [
    	compute => [
	    5 => 5,
	    5 => 5,
	    10 => 7,
	],
	value => 7,
    ],
    'Bivio::Math::EMA' => [
	new => [
	    -2 => Bivio::DieCode->DIE,
	    0 => Bivio::DieCode->DIE,
	    1 => undef,
	    2.5 => Bivio::DieCode->DIE,
	],
    ],
    50 => [
	value => Bivio::DieCode->DIE,
    ],
]);
