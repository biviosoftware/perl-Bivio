# Copyright (c) 2003 bivio Software Artisans, Inc.  All rights reserved.
# $Id$
#
# Test static utils, e.g. merge, that can be tested with Bivio::Test.
#
use strict;
use Bivio::Test;
Bivio::Test->unit([
    'Bivio::IO::Config' => [
	merge => [
	    [{}, {a => 1, b => {a => 2}, c => {b => {a => 3}}}] =>
	        [{a => 1, b => {a => 2}, c => {b => {a => 3}}}],
	    [{a => 1, b => {a => 2}, c => {b => {a => 3}}}, {}] =>
	        [{a => 1, b => {a => 2}, c => {b => {a => 3}}}],
	    [{a => 1, b => {a => 2}, c => {b => {a => 3}}},
		{a => 99, b => 99, c => {b => {a => 99}}}] =>
	        [{a => 1, b => {a => 2}, c => {b => {a => 3}}}],
	    [{a => [1, 2]}, {a => [3, 4]}, 1] =>
	        [{a => [1..4]}],
	    [{a => [1, 2]}, {a => [3, 4]}, 0] =>
	        [{a => [1, 2]}],
	    [{a => {a_1 => [1, 2]}}, {a => {a_1 => [3, 4]}}, 1] =>
	        [{a => {a_1 => [1..4]}}],
	],
    ],
]);
