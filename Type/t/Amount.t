#!perl -w
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::TypeError;
use Bivio::Type::Amount;

Bivio::Test->unit([
    'Bivio::Type::Amount' => [
	add => [
	    ['12', '0.5'] => ['12.500000'],
	],
    ],
]);
