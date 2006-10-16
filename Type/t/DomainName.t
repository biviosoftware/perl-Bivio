# Copyright (c) 2002 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::Type::DomainName;
use Bivio::TypeError;
Bivio::Test->unit([
    'Bivio::Type::DomainName' => [
	{
	    method => 'from_literal',
	    check_return => sub {
		my($case, $return, $expect) = @_;
		$case->actual_return([defined($return->[0]) ? $return->[0]
		    : $return->[1] ? $return->[1]->get_name : 'NULL']);
		return $expect;
	    },
	} => [
	    a => 'DOMAIN_NAME',
	    [undef] => 'NULL',
	    '' => 'NULL',
	    "1.1.1." . ('a' x 255) => 'TOO_LONG',
	    'SomeMixed.Case' => 'somemixed.case',
	    '1.1.1.1' => '1.1.1.1',
	    '  111.11.1.0 ' => '111.11.1.0',
	],
    ],
]);
