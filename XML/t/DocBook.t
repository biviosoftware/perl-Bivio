#!perl -w
use strict;
use Bivio::Test;
use Bivio::IO::File;
use Bivio::XML::DocBook;
Bivio::Test->unit([
    'Bivio::XML::DocBook' => [
	to_html => [
	    map {
		my($html) = $_;
		$html =~ s/xml$/html/;
		[$_] => [Bivio::IO::File->read($html)];
	    } <DocBook/*.xml>
	],
    ],
]);

