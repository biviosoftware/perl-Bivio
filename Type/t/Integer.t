#!perl -w
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::Type::Integer;
use Bivio::TypeError;
Bivio::Test->unit([
    'Bivio::Type::Integer' => [
    	get_min => [
	    [] => [-999999999],
	],
	get_max => [
	    [] => [999999999],
	],
	get_precision => [
	    [] => [9],
	],
	get_width => [
	    [] => [10],
	],
	get_decimals => [
	    [] => [0],
	],
	can_be_zero => [
	    [] => [1],
	],
	can_be_positive => [
	    [] => [1],
	],
	can_be_negative => [
	    [] => [1],
	],
	from_literal => [
	    ['9'] => [9],
	    ['+00009'] => [9],
	    ['-00009'] => [-9],
	    ['x'] => [undef, Bivio::TypeError->INTEGER],
	    [undef] => [undef],
	    [''] => [undef],
	    [' '] => [undef],
	    ['-99999999999999'] => [undef, Bivio::TypeError->NUMBER_RANGE],
	    ['-00000000000009'] => [-9],
	    ['+00000000000009'] => [9],
	    ['-999999999'] => [-999999999],
	    ['+999999999'] => [999999999],
	    ['+1000000000'] => [undef, Bivio::TypeError->NUMBER_RANGE],
	    ['-1000000000'] => [undef, Bivio::TypeError->NUMBER_RANGE],
	],
    ],
    Bivio::Type::Integer->new(1,10) => [
    	get_min => [
	    [] => ['1'],
	],
	get_max => [
	    [] => ['10'],
	],
	get_precision => [
	    [] => [2],
	],
	get_width => [
	    [] => [2],
	],
	get_decimals => [
	    [] => [0],
	],
	can_be_zero => [
	    [] => [0],
	],
	can_be_positive => [
	    [] => [1],
	],
	can_be_negative => [
	    [] => [0],
	],
	from_literal => [
	    ['00001'] => [1],
	    ['+00001'] => [1],
	    ['0'] => [undef, Bivio::TypeError->NUMBER_RANGE],
	    ['11'] => [undef, Bivio::TypeError->NUMBER_RANGE],
	    ['-00001'] => [undef, Bivio::TypeError->NUMBER_RANGE],
	    [undef] => [undef],
	    ['-00000000000009'] => [undef, Bivio::TypeError->NUMBER_RANGE],
	    ['+00000000000009'] => [9],
	],
    ],
]);
