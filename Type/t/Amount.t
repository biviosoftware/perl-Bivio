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
	    ['33', '.33'] => ['33.330000'],
	    ['33.33', '33.339'] => ['66.669000'],
	],
	sub => [
	    ['77.46', '0'] => ['77.460000'],
        ],
	mul => [
	    ['0.000004', '0.6'] => ['0.000002'],
	    ['0.000004', '0.7'] => ['0.000003'],
	    ['0.000249', '0.01'] => ['0.000002'],
	    ['0.000250', '0.01'] => ['0.000003'],
        ],
	div => [
	    ['10', '3'] => ['3.333333'],
	    ['10', '6'] => ['1.666667'],
	    ['0.000249', '100'] => ['0.000002'],
	    ['0.000250', '100'] => ['0.000003'],
            # rounding toward +inf, so I guess this is correct
	    ['-0.000250', '100'] => ['-0.000002'],
            ['100', '0'] => ['inf'],
	],
        abs => [
            ['123'] => ['123.000000'],
            ['-123'] => ['123.000000'],
        ],
        from_literal => [
            ['$1,200.06'] => ['1200.060000'],
            ['(123)'] => ['-123.000000'],
            ['1 2/3'] => ['1.666667'],
            ['x'] => [undef, Bivio::TypeError->NUMBER],
        ],
        fraction_as_string => [
            ['123.456', 2] => ['46'],
        ],
        neg => [
            ['123'] => ['-123.000000'],
            ['-123'] => ['123.000000'],
        ],
        round => [
            ['1.555', 2] => ['1.56'],
        ],
        trunc => [
            ['1.555', 2] => ['1.55'],
        ],
    ],
]);
