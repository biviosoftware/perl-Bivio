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
	    '"Mary Joe"@2.example.com'
	        => ['"Mary Joe"@2.example.com', undef],
	    'PoorImpl.com <hackers@foo.com>'
	        => ['hackers@foo.com', 'PoorImpl.com'],
	    'joe@example.com,mary@example.com' =>
	        ['joe@example.com', undef, 'mary@example.com'],
	],
	parse_list => [
	    'joe@example.com,mary@example.com' =>
	        [['joe@example.com', 'mary@example.com']],
	    'jed@example.com,'
	        . 'Joe Bob <joe@example.com>, '
	        . '"Jim Bob" <jim@example.com> , '
	        . 'jef@example.com (Jef Bob) ,'
	        . '"Mary Joe"@2.example.com,'
	        . 'PoorImpl.com <hackers@foo.com>,'
	        => [['jed@example.com', 'joe@example.com', 'jim@example.com',
		     'jef@example.com', '"Mary Joe"@2.example.com',
		    'hackers@foo.com']],
	],
    ],
]);

