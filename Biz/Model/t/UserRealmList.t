# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::PetShop::Util;
use Bivio::Test::ListModel;
Bivio::Test::Request->get_instance->set_realm(Bivio::PetShop::Util->DEMO_USER);
Bivio::Test::ListModel->unit('UserRealmList', [
    load_all => [
	# There may be orders;  We testing find_row_by_type, not load_all.
	[] => undef,
    ],
    find_row_by_type => [
	[Bivio::Auth::RealmType->USER] => 1,
	[Bivio::Auth::RealmType->CLUB] => 0,
    ],
]);
