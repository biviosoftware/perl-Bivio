#!perl -w
# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::TypeError;
use Bivio::Type::ECCreditCardNumber;

Bivio::Test->unit([
    'Bivio::Type::ECCreditCardNumber' => [
	from_literal => [map {
	    ([$_] => [$_]);
	    }
	    # Visa
	    '4222222222222',
	    # MC
	    '5222222222222227',
	    # AMEX
	    '342222222222223',
	],
    ],
]);
