# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
use strict;
use Bivio::Test;
Bivio::Test->new('Bivio::Mail::Address')->unit([
    'Bivio::Mail::Address' => [
	parse => [
	    'Joe Bob <joe@example.com>' => ['joe@example.com', 'Joe Bob'],
	    '"Joe Bob" <joe@example.com>' => ['joe@example.com', 'Joe Bob'],
	    'joe@example.com' => ['joe@example.com', undef],
	    'joe@example.com (Joe Bob)' => ['joe@example.com', 'Joe Bob'],
	    '"Mary Jones"@2.example.com,example.com.com'
	        => ['"Mary Jones"@2.example.com', undef],
#TODO: doesn't work, don't even konw if correct...
#	    'complex@2.example.com,example.com.com (My comment)'
#	        => ['complex@2.example.com', 'My Comment'],
	    'PoorImpl.com <hackers@foo.com>'
	        => ['hackers@foo.com', 'PoorImpl.com'],
	],
    ],
]);

