# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::TypeError;
Bivio::Test->new('Bivio::Type::USZipCode9')->unit([
    'Bivio::Type::USZipCode9' => [
	from_literal => [
	    ['12345'] => [undef, Bivio::TypeError->US_ZIP_CODE_9],
	    ['10000-0000'] => ['100000000'],
	],
    ],
]);
