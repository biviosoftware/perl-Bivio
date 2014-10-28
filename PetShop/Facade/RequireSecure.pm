# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Facade::RequireSecure;
use strict;
use Bivio::Base 'Facade.PetShop';


__PACKAGE__->new({
    uri => 'requiresecure',
    http_host => 'requiresecure.bivio.biz',
    mail_host => 'requiresecure.bivio.biz',
    is_production => 1,
    clone => 'PetShop',
    Constant => [
	[require_secure => 1],
    ],
});

1;
