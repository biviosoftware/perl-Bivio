# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::HTML::t::Scraper::T1;
Bivio::Test->unit([
    Bivio::HTML::t::Scraper::T1->new(Bivio::IO::File->mkdir_p('Scraper/log'))
    => [
	login => undef,
    ],
]);
