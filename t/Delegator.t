# Copyright (c) 2004 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
BEGIN {
    use Bivio::IO::Config;
    Bivio::IO::Config->introduce_values({
	Bivio::BConf->merge_class_loader({
	    delegates => {
		'Bivio::t::Delegator::D1' => 'Bivio::t::Delegator::I1',
	    },
	}),
    });
}
use Bivio::Test;
Bivio::Test->new({
    class_name => 'Bivio::t::Delegator::D1',
    method_is_autoloaded => 1,
})->unit([
    some_value => [
	value => 'some_value',
	does_not_exist => Bivio::DieCode->DIE,
    ],
    'Bivio::t::Delegator::D1' => [
	static_echo => [
	    hello => 'hello',
        ],
	static_does_not_exist => Bivio::DieCode->DIE,
    ],
]);
