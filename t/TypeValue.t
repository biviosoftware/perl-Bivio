# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::TypeValue;
use Bivio::Type::Integer;
my($I) = Bivio::Type::Integer->new(0, 1);
Bivio::Test->new('Bivio::TypeValue')->unit([
    ['Bivio::Type::Integer', 0] => [
	equals => [
	    [Bivio::TypeValue->new('Bivio::Type::Integer', 0)] => 1,
	    [Bivio::TypeValue->new('Bivio::Type::Integer', 1)] => 0,
	    [Bivio::TypeValue->new($I, 1)] => 0,
	    [undef] => 0,
	],
	as_string => 'Bivio::Type::Integer[0]',
    ],
]);
