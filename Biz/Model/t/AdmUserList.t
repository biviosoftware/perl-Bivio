# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::PetShop::Util;
use Bivio::Test::ListModel;
Bivio::Test::Request->get_instance;
Bivio::Test::ListModel->new('AdmUserList')->unit([
    load_all => [
	[{search => Bivio::PetShop::Util->DEMO_USER_LAST_NAME}] => [
	    map(({
		'User.first_name' => ucfirst($_),
		'User.middle_name' => undef,
	    }), sort(@{Bivio::PetShop::Util->demo_users})),
	],
    ],
]);
