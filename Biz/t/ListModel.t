# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Request;
my($req) = Bivio::Test::Request->get_instance;
my($tmp);
Bivio::Test->new({
    class_name => 'Bivio::Biz::ListModel',
    create_object => sub {
	my($case, $object) = @_;
	return $case->get('class_name')->new(
	    $req,
	    Bivio::IO::ClassLoader->simple_require(
		'Bivio::Biz::t::ListModel::' . $object->[0]),
	);
    },
})->unit([
    map(
	($_ => [map(
	    (@$_ => [
		[] => [[{
		    'RealmOwner.name' => 'club',
		    'RealmOwner.realm_id' => '3',
		}]],
	    ]),
	    [load_all => undef, 'map_rows'],
	    ['map_iterate'],
	)]),
	qw(T1List T2List),
    ),
]);
