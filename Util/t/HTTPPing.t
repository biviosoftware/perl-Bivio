# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Util::HTTPPing;
use Bivio::Test;
Bivio::Test->unit([
    Bivio::Util::HTTPPing => [
	page => [
	    ['http://www.bivio.biz/hm/contact'] => [''],
	    ['http://www.bivio.biz'] => [''],
	    ['http://www.bivio.biz/not-found'] => qr/\b404\b/,
	],
    ],
]);
