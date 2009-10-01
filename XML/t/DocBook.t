# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::IO::File;
Bivio::Test->new('Bivio::XML::DocBook')->unit([
    'Bivio::XML::DocBook' => [
	to_html => [
	    map((
		["$_.xml"] => $_ =~ /dev/
		   ? Bivio::DieCode->DIE
		   : _read("$_.html"),
	    ), sort(map(/(.*)\.xml$/, <DocBook/*.xml>))),
	],
        count_words => [
	    ['DocBook/01.xml'] => ["4\n"],
	    ['DocBook/02.xml'] => ["13\n"],
	    # Certain punctuation is counted as words.
	    ['DocBook/03.xml'] => ["26\n"],
	],
    ],
]);

sub _read {
    my($v) = Bivio::IO::File->read(shift);
    chomp($$v);
    return [$v];
}
