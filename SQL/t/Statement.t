# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
Bivio::Test->new('Bivio::SQL::Statement')->unit([
    {
	object => [],
	compute_return => sub {
	    return [shift->get('object')->get('where', 'params')];
	},
    } => [
	append_where_and => [
	    ['x'] => [' AND (x)', []],
	    ['y=?', [1]] => [' AND (x) AND (y=?)', [1]],
	    ['z', []] => [' AND (x) AND (y=?) AND (z)', [1]],
	],
	insert_params => [
	    [[]] => [' AND (x) AND (y=?) AND (z)', [1]],
	    [[2]] => [' AND (x) AND (y=?) AND (z)', [2, 1]],
	],
    ],
]);
