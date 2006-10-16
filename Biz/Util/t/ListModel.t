# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Request;
Bivio::Test::Request->setup_facade->set_realm_and_user('demo');
Bivio::Test->new('Bivio::Biz::Util::ListModel')->unit([
    'Bivio::Biz::Util::ListModel' => [
	csv => [
	    [qw(ProductList p=DOGS)]
	        => qr{DOGS,Corgi.*Poodle.*Notes.*Command}s,
	],
    ],
]);
