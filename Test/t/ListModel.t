# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
Bivio::Test->new({
    class_name => 'Bivio::Test::ListModel',
    compute_return => sub {
	return shift->get('object')->get('passed');
    },
})->unit([
    [{
	model => 'Bivio::Test::t::ListModel::T1List',
	# Comment out to debug
	print => sub {},
    }] => [
	unit => [
	    [[
		load_page => [
		    [{count => 0}] => [],
		    [{count => 1}] => [
			{
			    f1 => 1,
			},
		    ],
		    [{count => 2}] => [
			{
			    f1 => 1,
			    f2 => 1,
			}, {
			    f1 => 2,
			    f2 => 2,
			},
		    ],
		    # Produces a warning
		    [{count => 0}] => [[]],
		],
		get_field_type => [
		    f1 => 'Bivio::Type::Integer',
		],
		load_all => undef,
	    ]] => [1..6],
	],
     ],
]);
