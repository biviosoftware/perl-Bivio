#!perl -w
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::TypeError;
Bivio::Test->unit([
    'Bivio::Type::Amount' => [
	add => [
	    ['12', '0.5'] => ['000'],
	],
    ],
]);
