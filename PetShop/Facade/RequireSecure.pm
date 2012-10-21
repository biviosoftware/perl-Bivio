# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Facade::RequireSecure;
use strict;
use Bivio::Base 'Facade.PetShop';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

__PACKAGE__->new({
    uri => 'requiresecure',
    http_host => 'requiresecure.bivio.biz',
    mail_host => 'requiresecure.bivio.biz',
    clone => 'PetShop',
    Constant => [
	[require_secure => 1],
    ],
});

1;
