# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
use strict;
use Bivio::Test;
Bivio::Test->new('Bivio::Mail::Address')->unit([
    'Bivio::Mail::Address' => [
	parse => [
	    'Joe Bob <joe@bob.com>' => ['joe@bob.com', 'Joe Bob'],
	    '"Joe Bob" <joe@bob.com>' => ['joe@bob.com', 'Joe Bob'],
	    'joe@bob.com' => ['joe@bob.com', undef],
	    'joe@bob.com (Joe Bob)' => ['joe@bob.com', 'Joe Bob'],
	    '"Mary Jones"@addr.com,addr2.com'
	        => ['"Mary Jones"@addr.com', undef],
#TODO: doesn't work, don't even konw if correct...
#	    'complex@addr.com,addr2.com (My comment)'
#	        => ['complex@addr.com', 'My Comment'],
	    'PoorImpl.com <hackers@foo.com>'
	        => ['hackers@foo.com', 'PoorImpl.com'],
	],
    ],
]);

