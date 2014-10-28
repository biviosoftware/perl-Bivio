# Copyright (c) 1999-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Percent;
use strict;
use Bivio::Base 'Type.Amount';


sub calculate {
    # (proto, string, string) : string
    # Returns 100 * amount / total.
    # Returns 0 if total is 0.
    my($proto, $amount, $total) = @_;
    return $total == 0
	? 0
	: $proto->div($proto->mul($amount, 100), $total);
}

1;
