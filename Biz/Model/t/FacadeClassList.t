# Copyright (c) 2003 bivio Software, Inc.  All rights reserved.
# $Id$
#
use strict;
use Bivio::PetShop::Test::Request;
my($req) = Bivio::PetShop::Test::Request->setup_all_facades;
Bivio::Test->new('Bivio::Biz::Model::FacadeClassList')->unit([
    [$req] => [
	load_all => undef,
	map_rows => [
	    [] => [[{simple_name => 'PetShop'}]],
	],
    ],
]);
