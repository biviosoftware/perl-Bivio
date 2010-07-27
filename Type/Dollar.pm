# Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::Dollar;
use strict;
use Bivio::Base 'Bivio::Type::Amount';

# C<Bivio::Type::Dollar>

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_decimals {
    # : int
    # Returns 2.
    return 2;
}

sub get_max {
    # : string
    # Returns '9999999999999.99'.
    return '9999999999999.99';
}

sub get_min {
    # : string
    # Returns '-9999999999999.99'.
    return '-9999999999999.99';
}

1;
