#!perl -w
# $Id$

use strict;
use Bivio::Test;
use Bivio::Type::Password;
Bivio::Test->new('Bivio::Type::Password')->unit([
    [] => [
	INVALID => 'xx',
	encrypt => [
	    ['foo'] => qr/[\w]+/,
	],
#	salt => [
#	    [ 2 ] => qr/[\w]{2}/,
#	],
	from_literal => [ map({
	    [$_] => [undef, Bivio::TypeError::PASSWORD];
	} qw(aaaaa 12345)),
	    ['123456'] => qr/[\w]+/,
	],
    ],
]);
