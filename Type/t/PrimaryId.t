#!perl -w
# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
Bivio::Test->new('Bivio::Type::PrimaryId')->unit([
    'Bivio::Type::PrimaryId' => [
	to_parts => [
	    '100001' => [{
		version => 0,
		type => 1,
		site => 0,
		number => 1,
	     }],
	    '111111111111100001' => [{
		version => 0,
		type => 1,
		site => 0,
		number => '1111111111111',
	     }],
	    '1' => Bivio::DieCode->DIE,
	],
	from_parts => [
	    [{
		version => 0,
		type => 1,
		site => 0,
		number => 1,
	    }] => '100001',
	    [{
		version => 0,
		type => 1,
		site => 1,
		number => '1111111111111',
	    }] => '111111111111100101',
	],
    ],
]);
