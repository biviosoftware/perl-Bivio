#!perl -w
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::TypeError;
use Bivio::Type::CreditCardNumber;

Bivio::Test->unit([
    'Bivio::Type::CreditCardNumber' => [
	{
	    method => 'from_literal',
	    # Expect is always params->[0]
	    result_ok => sub {
		my($object, $method, $params, $expect, $actual) = @_;
		return Bivio::Test->default_result_ok(
		    $object, $method, $params, $params, $actual);
	    },
	} => [
	    # Visa
	    ['4222222222222'] => [],
	    # MC
	    ['5222222222222227'] => [],
	    # AMEX
	    ['342222222222223'] => [],
	],
    ],
]);
