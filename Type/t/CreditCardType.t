#!perl -w
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::Type::CreditCardType;
use Bivio::TypeError;
Bivio::Test->unit([
    'Bivio::Type::CreditCardType' => [
	get_by_number => [
	    ['4222222222222'] => [Bivio::Type::CreditCardType->VISA],
	    ['5222222222222227'] => [Bivio::Type::CreditCardType->MASTERCARD],
	    ['342222222222223'] => [Bivio::Type::CreditCardType->AMEX],
	],
    ],
]);
