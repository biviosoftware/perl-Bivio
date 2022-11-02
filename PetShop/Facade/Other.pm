# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Facade::Other;
use strict;
use Bivio::Base 'Facade.PetShop';


__PACKAGE__->new({
    uri => 'other',
    http_host => 'other.bivio.biz',
    mail_host => 'other.bivio.biz',
    is_production => 1,
    clone => 'PetShop',
    HTML => __PACKAGE__->make_groups(__PACKAGE__->bunit_shared_values),
    Color => [
        [body_background => 0xff88ff],
    ],
    Constant => __PACKAGE__->make_groups([
        @{__PACKAGE__->bunit_shared_values},
        shared_value2 => 'Other',
        robots_txt_allow_all => 0,
        site_reports_realm_name => undef,
    ]),
    Text => __PACKAGE__->make_groups([
        @{__PACKAGE__->bunit_shared_values},
        shared_value2 => 'Other',
    ]),
});

1;
