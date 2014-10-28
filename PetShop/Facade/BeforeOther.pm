# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Facade::BeforeOther;
use strict;
use Bivio::Base 'Facade.Other';


__PACKAGE__->new({
    uri => 'beforeother',
    http_host => 'beforeother.bivio.biz',
    mail_host => 'beforeother.bivio.biz',
    is_production => 1,
    clone => 'Other',
    Constant => __PACKAGE__->make_groups([
	@{__PACKAGE__->bunit_shared_values},
	shared_value2 => 'BeforeOther',
    ]),
    Text => __PACKAGE__->make_groups([
	@{__PACKAGE__->bunit_shared_values},
	shared_value1 => 'BeforeOther',
    ]),
});

1;
