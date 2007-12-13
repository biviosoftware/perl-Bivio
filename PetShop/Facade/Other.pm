# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Facade::Other;
use strict;
use Bivio::Base 'UI.FacadeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

__PACKAGE__->new({
    uri => 'other',
    http_host => 'other.bivio.biz',
    mail_host => 'other.bivio.biz',
    clone => 'PetShop',
});

1;
