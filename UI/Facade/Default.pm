# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Facade::Default;
use strict;
use Bivio::Base 'UI.FacadeBase';


__PACKAGE__->new({
    is_production => 1,
    http_host => 'default.bivio.biz',
    mail_host => 'default.bivio.biz',
    uri => 'default.bivio.biz',
});

1;
