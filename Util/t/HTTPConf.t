# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
Bivio::Test->new('Bivio::Util::HTTPConf')->unit([
    'Bivio::Util::HTTPConf' => [
	gen_app => [
	    petshop => 'etc/httpd/petshop.conf',
	],
    ],
]);
