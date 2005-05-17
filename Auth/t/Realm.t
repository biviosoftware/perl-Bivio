# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Request;
my($req) = Bivio::Test::Request->initialize_fully;
Bivio::Test->new('Bivio::Auth::Realm')->unit([
    {
	check_return => sub {
	    my($case, $actual, $expect) = @_;
	    my($o) = $actual->[0];
	    $case->actual_return([
		$o->get('type')->get_name,
		$o->is_default,
		Bivio::Die->eval(sub {$o->format_file}),
	    ]);
	    return $expect;
	},
        object => 'Bivio::Auth::Realm',
    } => [
	new => [
	    [] => Bivio::DieCode->DIE,
	    ['demo', $req] => ['USER', 0, 'demo'],
	    ['user', $req] => ['USER', 1],
	    ['club', $req] => ['CLUB', 1],
	    ['general', $req] => ['GENERAL', 1],
	],
	get_general => [
	    [] => ['GENERAL', 1],
	],
    ],
    ['demo', $req] => [
	format_email => qr/\bdemo@/,
	format_file => 'demo',
	format_uri => '/demo',
	as_string => qr/\bBivio::Auth::Realm\(USER,demo,\d+\)\b/,
	get_default_name => 'user',
	get_type => [
	    [] => [Bivio::Auth::RealmType->USER],
	],
	is_default => 0,
	is_default_id => [
	    sub {
		return [shift->get_nested(qw(object id))];
	    } => 0,
	],
    ],
    sub {
	return Bivio::Auth::Realm::General->get_general;
    } => [
	format_email => Bivio::DieCode->DIE,
    ],
    'Bivio::Auth::Realm' => [
	is_default_id => [
	    1 => 1,
	    2 => 1,
	],
    ],
]);
