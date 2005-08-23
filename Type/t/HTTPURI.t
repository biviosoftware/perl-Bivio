#!perl -w
# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::TypeError;
Bivio::Test->new('Bivio::Type::HTTPURI')->unit([
    'Bivio::Type::HTTPURI' => [
        from_literal => [
	    '' => [undef, undef],
	    'http://example.com' => 'http://example.com',
	    'https://example.com' => 'https://example.com',
	    'gobbledygook://example.com' => [undef, Bivio::TypeError->HTTPURI],
	    'http:/' => [undef, Bivio::TypeError->HTTPURI],
	    'ftp://example.com' => [undef, Bivio::TypeError->HTTPURI],
	    '/foo' => [undef, Bivio::TypeError->HTTPURI],
        ],
    ],
]);
