# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::IO::Ref;
use Bivio::Test;
Bivio::Test->unit([
    'Bivio::IO::Ref' => [
	[undef, undef] => [1],
	[undef, ''] => [0],
	['', ''] => [1],
	['', ''] => [1],
	[{a => 1}, {a => 1}] => [1],
	[{a => 1}, {a => 1}] => [1],
	[{1, [2]}, {1, [2]}] => [1],
	[{1, [2, {]}, {1, [2]}] => [1],
	for_category => [
	    [Zoe::Type::Category->COMMUNICATION] => sub {
		my(undef, $return) = @_;
		return $return->[0]->[0] =~ /^You over-hear Lois talking/
		    ? 1 : 0;
	    },
	],
    ],
]);
sub _s {
    my($s) = @_;
    return \$s;
}

	
