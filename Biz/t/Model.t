# $Id$
# Copyright (c) 2003 bivio Software Artisans, Inc.  All rights reserved.
#
# Only works with PetShop configuration
#
use strict;
use Bivio::Test;
use Bivio::Test::Request;
my($_req) = Bivio::Test::Request->get_instance;
my($_categories) = [];
my($_category_count) = 0;
Bivio::Test->new('Bivio::Biz::Model')->unit([
    'Bivio::Biz::Model' => [
	internal_initialize_local_fields => [
	    map({
		($_ => [[
		    {
			name => 'a',
			type => 'String',
			constraint => 'NONE',
		    },
		]]);
	    }
		[[[qw(a String NONE)]]],
		[[['a', undef, 'NONE']], 'String'],
		[[['a', 'String', undef]], undef, 'NONE'],
		[['a'], qw(String NONE)],
	    ),
	    [[qw(a b)], qw(String NONE)] => [[
		map({
		    {
			name => $_,
			type => 'String',
			constraint => 'NONE',
		    };
	        } qw(a b)),
	    ]],
	    [['a']] => Bivio::DieCode->DIE,
	    [['a'], 'String'] => Bivio::DieCode->DIE,
	    [c1 => ['d1'], c2 => ['d2'], 'String', 'NOT_NULL'] => [
		[map({
		    ("c$_" => [
			{
			    name => "d$_",
			    type => 'String',
			    constraint => 'NOT_NULL',
			},
		    ]);
		} 1 ..2)],
            ],
	    [c1 => [[qw(d1 Line NONE)]], c2 => [[qw(d2 String NOT_NULL)]]]
		=> [[
		    c1 => [{
			name => 'd1',
			type => 'Line',
			constraint => 'NONE',
		    }],
		    c2 => [{
			name => 'd2',
			type => 'String',
			constraint => 'NOT_NULL',
		    }],
		]],
	],
	new => [
	    ['RealmOwner'] => qr/RealmOwner/,
	    [$_req, 'RealmOwner'] => qr/RealmOwner/,
	    ['junk', 'RealmOwner'] => Bivio::DieCode->DIE,
	    [] => Bivio::DieCode->DIE,
	],
    ],
    'Bivio::Biz::Model::UserLoginForm' => [
	merge_initialize_info => [
	    [{
		auth_id => ['p'],
		order_by => ['p1'],
		visible => ['p1', {name => 'p2', in_list => 1}],
	    }, {
		auth_id => ['c'],
		order_by => ['c1'],
		visible => ['c2'],
		hidden => ['p2'],
	    }] => [{
		auth_id => ['c'],
		order_by => ['p1', 'c1'],
		visible => ['c2', 'p1'],
		hidden => [{name => 'p2', in_list => 1}],
	    }],
	],
    ],
    'Bivio::Biz::Model::RealmOwner' => [
	new => [
	    [] => qr/Bivio::Biz::Model::RealmOwner/,
	    [$_req] => qr/RealmOwner/,
	    [$_req, 'RealmUser'] => qr/RealmUser/,
	    ['junk', 'RealmUser'] => Bivio::DieCode->DIE,
	],
    ],
    ['RealmOwner'] => [
	get_field_info => [
	    ['name', 'type'] => 'Bivio::Type::RealmName',
        ],
	new => [
	    [] => qr/Bivio::Biz::Model::RealmOwner/,
	    [$_req] => qr/RealmOwner/,
	    [$_req, 'RealmUser'] => qr/RealmUser/,
	    ['junk', 'RealmUser'] => Bivio::DieCode->DIE,
	],
    ],
    [$_req, 'Category'] => [
	iterate_start => [
	    ['name desc'] => undef,
	],
	{
	    method => 'iterate_next_and_load',
	    check_return => sub {
		my($case, $actual, $expect) = @_;
		if ($actual->[0]) {
		    die('name out of order : prev=',
			$_categories->[$#$_categories]->{name},
			' this=',
			$case->get('object')->get('name'))
			if $actual->[0] && @$_categories
			    && $case->get('object')->get('name')
				gt $_categories->[$#$_categories]->{name};
		    push(@$_categories,
			$case->get('object')->get_shallow_copy);
		}
		return $expect;
	    },
	} => [
	    [] => 1,
	    [] => 1,
	    [] => 1,
	    [] => 1,
	    [] => 1,
	    [] => 0,
	],
	iterate_end => undef,
	map_iterate => [
	    [undef, 'name desc'] => [$_categories],
	    [undef, 'unauth_iterate_start', 'name desc'] => [$_categories],
	    # Must be closures, because depends on deferred eval of
	    # previous operations.
	    sub {
		my($case) = @_;
		return [sub {
		    return $case->get('object')->get('name');
	        }, 'name'];
	    } => sub {
		return [[map($_->{name}, reverse(@$_categories))]];
	    },
	],
	do_iterate => [
	    [
		sub {
		    $_category_count++;
		    return shift->get('name') ne $_categories->[2]->{name};
		},
		'name asc',
	    ] => sub {
		shift->actual_return([$_category_count]);
		return [3];
	    },
	],
    ],
]);
