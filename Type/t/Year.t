#!perl -w
# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::TypeError;
use Bivio::Type::DateTime;
use Bivio::Type::Year;
my($now) = Bivio::Type::DateTime->now_as_year;
my($now2) = $now % 100;
Bivio::Test->unit([
    'Bivio::Type::Year' => [
	from_literal => [
	    -1 => [undef, Bivio::TypeError->NUMBER_RANGE],
	    0 => Bivio::Type::DateTime->now_as_year
		- Bivio::Type::DateTime->now_as_year % 100,
	    $now => $now,
	    1901 => 1901,
	    $now2 => $now,
	    $now2 + 1 => $now + 1,
	    $now2 + Bivio::Type::Year->WINDOW_SIZE => $now + Bivio::Type::Year->WINDOW_SIZE,
	    $now2 + Bivio::Type::Year->WINDOW_SIZE + 1 => $now + Bivio::Type::Year->WINDOW_SIZE + 1 - 100,
	],
    ],
]);
