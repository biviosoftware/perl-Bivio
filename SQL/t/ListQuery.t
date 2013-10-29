# Copyright (c) 2005-2007 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::SQL::ListSupport;
use Bivio::Agent::Request;

# Set the timezone to something specific
# Bivio::Agent::Request->get_current_or_new->put(query => 120);

my($_SUPPORT1) = Bivio::SQL::ListSupport->new({
    version => 1,
    want_date => 1,
    date => [
	'RealmOwner.creation_date_time',
    ],
    order_by => [
	'RealmOwner.name',
	'RealmOwner.realm_id',
	'RealmOwner.creation_date_time',
    ],
    primary_key => [
	'RealmOwner.realm_id',
    ],
});

Bivio::Test->new('Bivio::SQL::ListQuery')->unit([
    [
	{
	    t => 35,
	    d => '12/12/2001',
	    b => '12/1/2001',
	    n => '13',
	    o => '2a',
	},
	$_SUPPORT1,
	'Bivio::Die',
    ] => [
	as_string => qr{^ListQuery\[b=[^=]+\&d=},
	get => [
	    begin_date => '2452245 79199',
	    date => '2452256 79199',
	    interval => [undef],
	    order_by => [[
		'RealmOwner.creation_date_time' => 1,
		'RealmOwner.name' => 1,
		'RealmOwner.realm_id' => 0,
	    ]],
	    page_number => 13,
	    parent_id => [undef],
	    search => [undef],
	    this => [[35]],
	    count => Bivio::DieCode->DIE(),
	],
    ],
    [
	{
	    order_by => [qw(RealmOwner.realm_id asc)],
	},
	$_SUPPORT1,
	'Bivio::Die',
    ] => [
	get => [
	    order_by => [[
		'RealmOwner.realm_id' => 1,
		'RealmOwner.name' => 1,
		'RealmOwner.creation_date_time' => 0,
	    ]],
	],
    ],
    [
	{
	    d => '12/12/2001 1:0:0',
	    b => '12/1/2001',
	    count => 3,
	},
	$_SUPPORT1,
	'Bivio::Die',
    ] => [
	get => [
	    begin_date => '2452245 79199',
	    date => '2452256 3600',
	    count => 3,
	],
    ],
    [
	{
	},
	$_SUPPORT1,
	'Bivio::Die',
    ] => [
	get => [
	    begin_date => [undef],
	    date => Bivio::Type::Date->local_end_of_today,
	],
    ],
    'Bivio::SQL::ListQuery' => [
	clean_raw => [
	    [{auth_id => 1}, $_SUPPORT1] => [{}],
	    [{auth_id => 1, count => 1}, $_SUPPORT1] => [{count => 1}],
	],
    ],
    [
	{
	    d => '12/12/2001 1:0:0',
	    p => '10001',
	    o => '1a',
	},
	$_SUPPORT1,
	'Bivio::Die',
    ] => [
	format_uri_for_this_as_parent => [
	    [$_SUPPORT1, ['20001']] => 'p=20001&d=2452256%203600',
	],
    ],
]);
