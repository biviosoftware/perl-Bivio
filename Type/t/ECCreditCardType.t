#!perl -w
# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::Type::ECCreditCardType;
use Bivio::TypeError;
Bivio::Test->unit([
    'Bivio::Type::ECCreditCardType' => [
	get_by_number => [
	    ['4222222222222'] => [Bivio::Type::ECCreditCardType->VISA],
	    ['5222222222222227'] => [Bivio::Type::ECCreditCardType
		->MASTERCARD],
	    ['342222222222223'] => [Bivio::Type::ECCreditCardType->AMEX],
	    ['6011222222222229'] => [Bivio::Type::ECCreditCardType->DISCOVER],
	],
    ],
]);
