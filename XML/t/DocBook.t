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
	    } sort(<DocBook/*.xml>)
	],
        count_words => [
	    ['DocBook/01.xml'] => ["4\n"],
	    ['DocBook/02.xml'] => ["13\n"],
	    # Certain punctuation is counted as words.
	    ['DocBook/03.xml'] => ["26\n"],
	],
    ],
]);

