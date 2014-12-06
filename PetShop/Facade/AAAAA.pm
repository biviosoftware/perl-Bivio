# Copyright (c) 2014 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Facade::AAAAA;
use strict;
use Bivio::Base 'Facade.PetShop';


__PACKAGE__->new({
    uri => 'aaaaa',
    http_host => 'aaaaa.bivio.biz',
    mail_host => 'aaaaa.bivio.biz',
    is_production => 0,
    clone => 'PetShop',
});

1;
