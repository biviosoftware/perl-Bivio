#!perl -w
use strict;
use Bivio::Test;
use Bivio::IO::File;
use Bivio::XML::DocBook;
Bivio::Test->unit([
    'Bivio::XML::DocBook' => [
	to_html => [
	    ['DocBook/01.xml'] => [Bivio::IO::File->read('DocBook/01.html')],
	],
    ],
]);

