# $Id$
# Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.
use strict;
use Bivio::Test;
use Bivio::Type::Secret;
Bivio::Test->new({
    check_return => sub {
	my($case, $return) = @_;
	my($reverse) = $case->get('method');
	$reverse =~ s/encrypt/decrypt/;
	return [$case->get('object')->$reverse($return->[0])];
    },
})->unit([
    Bivio::Type::Secret => [
	map {(
	    "encrypt_$_" => [
		map {([$_] => [$_])}
		    undef,
		    '',
		    'the quick brown fox ate the gingerbread boy',
		    '1',
		    time,
	    ],
        )} 'hex', 'http_base64'
    ],
])
;
