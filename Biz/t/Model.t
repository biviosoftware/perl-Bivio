# $Id$
# Copyright (c) 2003 bivio Software Artisans, Inc.  All rights reserved.
#
# Needs users
#
use strict;
use Bivio::Test;
use Bivio::Test::Request;
my($_req) = Bivio::Test::Request->get_instance;
Bivio::Test->new('Bivio::Biz::Model')->unit([
    'Bivio::Biz::Model' => [
	new => [
	    ['RealmOwner'] => qr/RealmOwner/,
	    [$_req, 'RealmOwner'] => qr/RealmOwner/,
	    ['junk', 'RealmOwner'] => Bivio::DieCode->DIE,
	    [] => Bivio::DieCode->DIE,
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
]);
