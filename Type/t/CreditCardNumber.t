#!perl -w
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::Type::CreditCardNumber;
use Bivio::TypeError;
Bivio::Test->unit([
    'Bivio::Type::CreditCardNumber' => [
	from_literal => [
	    # Visa
	    ['4222222222222'] => ['4222222222222'],
	    # MC
	    ['5222222222222227'] => ['5222222222222227'],
	    # AMEX
	    ['342222222222223'] => ['342222222222223'],
	],
    ],
]);
