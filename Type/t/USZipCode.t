# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::Type::USZipCode;
Bivio::Test->unit([
    'Bivio::Type::USZipCode' => [
	from_literal => [
	    [undef] => [undef],
	    [' '] => [undef],
	    ['1'] => [undef, Bivio::TypeError->US_ZIP_CODE],
	    ['1234'] => [undef, Bivio::TypeError->US_ZIP_CODE],
	    ['00000'] => ['00000'],
	    ['00001'] => ['00001'],
	    ['10000'] => ['10000'],
	    ['10000-'] => ['10000'],
	    ['12345-1'] => [undef, Bivio::TypeError->US_ZIP_CODE],
	    ['12345 0'] => [undef, Bivio::TypeError->US_ZIP_CODE],
	    ['10000-0000'] => ['100000000'],
	    ['12345 6789'] => ['123456789'],
	    ['123456789'] => ['123456789'],
	    ['0123456789'] => [undef, Bivio::TypeError->US_ZIP_CODE],
	    ['1234567890'] => [undef, Bivio::TypeError->US_ZIP_CODE],
	],
    ],
]);
