# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::Price;
use strict;
use Bivio::Base 'Type.Number';


sub get_decimals {
    return 2;
}

sub get_max {
    return '99999999.99';
}

sub get_min {
    return '-99999999.99';
}

sub get_precision {
    return 10;
}

1;
