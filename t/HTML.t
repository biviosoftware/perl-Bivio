# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
Bivio::Test->new('Bivio::HTML')->unit([
    'Bivio::HTML' => [
	escape_query => [
	    hello => 'hello',
	    'hello+bye' => 'hello%2Bbye',
	    'hello bye' => 'hello%20bye',
	    'hello&bye' => 'hello%26bye',
	    'hello?bye' => 'hello%3Fbye',
        ],
	unescape_query => [
	    hello => 'hello',
	    'hello%2Bbye' => 'hello+bye',
	    'hello%20bye' => 'hello bye',
	    'hello%26bye' => 'hello&bye',
	    'hello%3Fbye' => 'hello?bye',
        ],
    ],
]);
