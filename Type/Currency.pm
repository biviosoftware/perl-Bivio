# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::Currency;
use strict;
use Bivio::Base 'Type.Amount';


sub get_decimals {
    return 2;
}

sub get_max {
    return '9999999999999.99';
}

sub get_min {
    return '-9999999999999.99';
}

1;
