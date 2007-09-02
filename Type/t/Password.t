#!perl -w
# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
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
	is_equal => [
	    ['kzltIzEfODKJg', 'abcdef'] => 1,
	    ['kzltIzEfODKJg', '123456'] => 0,
	    ['kzltIzEfODKJg', undef] => 0,
	    [undef, 'abcdef'] => 0,
	    # Special case when both or undefined.
	    [undef, undef] => 0,
	],
	is_valid => [
	    kzltIzEfODKJg => 1,
	    abcdefg => 0,
	    otp => 1,
	    xx => 0,
	],
    ],
]);
