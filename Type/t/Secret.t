# $Id$
# Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.
use strict;
use Bivio::Test;
use Bivio::Type::Secret;
Bivio::Test->new({
    result_ok => sub {
	my($object, $method, $params, $expect, $actual) = @_;
	return 0 unless ref($actual) eq 'ARRAY';
	my($reverse) = $method;
	$reverse =~ s/encrypt/decrypt/;
	return 0 if defined($params->[0]) != defined($actual->[0]);
	return 1 unless defined($params->[0]);
	return $params->[0] eq $object->$reverse($actual->[0]);
    },
})->unit([
    Bivio::Type::Secret => [
	map {(
	    "encrypt_$_" => [
		map {([$_] => [])}
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
