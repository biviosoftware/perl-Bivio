# Copyright (c) 2004 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
BEGIN {
    use Bivio::IO::Config;
    Bivio::IO::Config->introduce_values({
	Bivio::BConf->merge_class_loader({
	    delegates => {
		'Bivio::Type::t::EnumDelegator::D1' =>
		    'Bivio::Type::t::EnumDelegator::I1',
	    },
	}),
    });
}
use Bivio::Test;
Bivio::Test->new('Bivio::Type::t::EnumDelegator::D1')->unit([
    'Bivio::Type::t::EnumDelegator::D1' => [
	from_name => [
	    N1 => sub {
		return [Bivio::Type::t::EnumDelegator::D1->N1];
	    },
	],
    ],
    {
	object => sub {Bivio::Type::t::EnumDelegator::D1->N1},
	method_is_autoloaded => 1,
    } => [
	inc_value => [
	    2 => 3,
	],
	does_not_exist => Bivio::DieCode->DIE,
    ],
]);
