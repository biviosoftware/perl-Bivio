# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
use Bivio::Test;
use Bivio::Collection::Attributes;
Bivio::Test->unit([
    Bivio::Collection::Attributes->new({
	a => '3',
	b => ['A', 'B'],
	c => {A => 1, B => 2},
	d => Bivio::Collection::Attributes->new({a => 99}),
    }) => [
	get_nested => [
	    a => 3,
	    ['b', 1] => ['B'],
	    ['c', 'B'] => 2,
	    ['d', 'a'] => 99,
	],
	{
	    method => 'get',
	    want_scalar => 1,
	} => [
	    ['a', 'b'] => Bivio::DieCode->DIE,
	    a => 3,
	],
	get_if_exists_else_put => [
	    [aa => 33] => 33,
	    [aa => 99] => 33,
	    [bb => sub {22}] => 22,
	    [bb => sub {44}] => 22,
	],
    ],
]);

