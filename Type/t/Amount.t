#!perl -w
# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::TypeError;
use Bivio::Type::Amount;

Bivio::Test->unit([
    'Bivio::Type::Amount' => [
        abs => [
            ['+123'] => ['123.000000'],
            ['123'] => ['123.000000'],
            ['-123'] => ['123.000000'],
            ['-12345678901234567890'] => ['12345678901234567890.000000'],
        ],
	add => [
	    ['12', '0.5'] => ['12.500000'],
	    ['33', '.33'] => ['33.330000'],
	    ['33.33', '33.339'] => ['66.669000'],
            ['12345678901234.123456', '10000000000000'] =>
                ['22345678901234.123456'],
            ['12,345,678,901,234.123456', '10000000000000'] =>
                ['22345678901234.123456'],
	],
	sub => [
	    ['77.46', '0'] => ['77.460000'],
            ['12', '0.5'] => ['11.500000'],
        ],
	mul => [
	    ['0.000004', '0.6'] => ['0.000002'],
	    ['0.000004', '0.7'] => ['0.000003'],
	    ['0.000249', '0.01'] => ['0.000002'],
	    ['0.000250', '0.01'] => ['0.000003'],
	    ['0.000250', '-0.01'] => ['-0.000002'],
            # these two test different things, literal and float 0.03
            ['0.03', '505.50', 2] => ['15.17'],
            [0.03, '505.50', 2] => ['15.17'],
        ],
	div => [
	    ['10', '3'] => ['3.333333'],
	    ['10', '6'] => ['1.666667'],
	    ['0.000249', '100'] => ['0.000002'],
	    ['0.000250', '100'] => ['0.000003'],
	    ['-0.000250', '100'] => ['-0.000002'],
            ['100', '0'] => Bivio::DieCode->DIE,
            ['100', undef] => Bivio::DieCode->DIE,
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
            ['-12345678901234567890'] => ['12345678901234567890.000000'],
        ],
        round => [
            ['1.555', 2] => ['1.56'],
            ['20.49', 0] => ['20'],
            ['20.5', 0] => ['21'],
            ['-20.5', 0] => ['-20'],
            ['-20.51', 0] => ['-21'],
            ['0.37498', 2] => ['0.37'],
            ['-0.37498', 2] => ['-0.37'],
            ['0.0005', 3] => ['0.001'],
            ['-0.0005', 3] => ['0.000'],
            ['0.00005', 4] => ['0.0001'],
            ['-0.00005', 4] => ['0.0000'],
            ['5.555555', 5] => ['5.55556'],
            ['-5.555555', 5] => ['-5.55555'],
        ],
        trunc => [
            ['1.555', 2] => ['1.55'],
            ['1.9999999999999', 0] => [1],
            ['-2.555', 1] => ['-2.5'],
        ],
        compare => [
            ['123', '123'] => [0],
            ['123', '-123'] => [1],
            ['-123', '123'] => [-1],
            ['123', '122.999999'] => [1],
            ['345678901234567890.123456',
                Bivio::Type::Amount->add('345678901234567890',
                    '.123456')] => [0],
        ],
        to_literal => [
            [undef] => [''],
            ['0'] => ['0'],
            ['0.'] => ['0'],
            ['.0'] => ['0'],
            ['0.0'] => ['0'],
            ['123.456'] => ['123.456'],
            ['123.45'] => ['123.45'],
            ['123.40'] => ['123.4'],
            ['123.0'] => ['123'],
            ['0.000000'] => ['0'],
            ['0.001000'] => ['0.001'],
            ['0123.0'] => ['123'],
        ],
        sign => [
            ['-123'] => ['-1'],
            ['0'] => ['0'],
            ['123'] => ['1'],
        ],
	min => [
	    ['1.0', '1.0'] => ['1.0'],
	    ['2.0', '1.0'] => ['1.0'],
	    ['-2.0', '1.0'] => ['-2.0'],
        ],
	max => [
	    ['1.0', '1.0'] => ['1.0'],
	    ['2.0', '1.0'] => ['2.0'],
	    ['-2.0', '1.0'] => ['1.0'],
        ],
    ],
]);
