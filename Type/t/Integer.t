#!perl -w
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::Type::Integer;
use Bivio::TypeError;
Bivio::Test->run([
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
	    [undef] => [undef],
	    [''] => [undef],
	    ['00009'] => [9],
	    ['+00009'] => [9],
	    ['-00009'] => [-9],
	    ['-99999999999999'] => [undef, Bivio::TypeError->NUMBER_RANGE],
	    ['-00000000000009'] => [-9],
	    ['+00000000000009'] => [9],
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
	    [undef] => [undef],
	    ['00009'] => [9],
	    ['+00009'] => [9],
	    ['-00009'] => [undef, Bivio::TypeError->NUMBER_RANGE],
	    ['0'] => [undef, Bivio::TypeError->NUMBER_RANGE],
	    ['11'] => [undef, Bivio::TypeError->NUMBER_RANGE],
	    ['-00000000000009'] => [undef, Bivio::TypeError->NUMBER_RANGE],
	    ['+00000000000009'] => [9],
	],
    ],
]);
