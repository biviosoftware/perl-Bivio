# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Facade::Mobile;
use strict;
use Bivio::Base 'Facade.PetShop';


__PACKAGE__->new({
    clone => 'PetShop',
    is_production => 1,
    http_host => 'm.petshop.bivio.biz',
    mail_host => 'm.petshop.bivio.biz',
    uri => 'm.petshop',
    Text => [
    	[home_page_uri => '/bp'],
    ],
});

1;
