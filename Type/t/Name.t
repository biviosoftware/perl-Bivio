# Copyright (c) 2002 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::Type::Name;
use Bivio::TypeError;
Bivio::Test->unit([
    'Bivio::Type::Name' => [
	{
	    method => 'from_literal',
	    check_return => sub {
		my($case, $return, $expect) = @_;
		$case->actual_return([defined($return->[0]) ? $return->[0]
		    : $return->[1] ? $return->[1]->get_name : 'NULL']);
		return $expect;
	    },
	} => [
	    a => 'a',
	    [undef] => 'NULL',
	    '' => 'NULL',
	    a123456789012345678901234567890 => 'TOO_LONG',
	    SomeMixedCase => 'SomeMixedCase',
	],
    ],
]);
