# Copyright (c) 2004-2007 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
my($delegate, $delegator);
BEGIN {
    use Bivio::IO::Config;
    Bivio::IO::Config->introduce_values({
	Bivio::BConf->merge_class_loader({
	    delegates => {
		$delegator = 'Bivio::Type::t::EnumDelegator::D1' =>
		    $delegate = 'Bivio::Type::t::EnumDelegator::I1',
	    },
	}),
    });
}
use Bivio::Test;
Bivio::Test->new({
    class_name => $delegator,
    method_is_autoloaded => 1,
})->unit([
    $delegator => [
	from_name => [
	    N1 => sub {
		return [$delegator->N1];
	    },
	],
    ],
    {
	object => sub {$delegator->N1},
    } => [
	inc_value => [
	    2 => 3,
	],
	does_not_exist => Bivio::DieCode->DIE,
    ],
    $delegator => [
	does_not_exist => Bivio::DieCode->DIE,
	static_exists => $delegate,
    ],
]);
