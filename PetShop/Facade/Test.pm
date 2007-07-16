# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Facade::Test;
use strict;
use Bivio::Base 'Bivio::UI::FacadeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_SELF) = __PACKAGE__->new({
    uri => 'test',
    http_host => 'test.bivio.biz',
    mail_host => 'bivio.biz',
    Text => [
	[home_page_uri => '/index.html'],
	[site_name => q{This is a Test}],
	[site_copyright => q{bivio Software, Inc.}],
	[site_root_realm => 'site'],
    ],
});

1;
