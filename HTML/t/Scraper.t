# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::IO::File;
Bivio::IO::Config->introduce_values({
    'Bivio::Test::Language::HTTP' => {
	home_page_uri => 'http://petshop.bivio.biz',
    },
});
Bivio::Test->new('Bivio::HTML::t::Scraper::T1')->unit([
    [Bivio::IO::File->mkdir_p('Scraper/log')] => [
	login => undef,
    ],
]);
