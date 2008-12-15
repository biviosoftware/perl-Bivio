# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::PageSize;
use strict;
use Bivio::Base 'Bivio::Type::Integer';

# C<Bivio::Type::PageSize> is the number of lines on a page for
# ListModel queries.  It is a user preference.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_default {
    # (self) : int
    # Returns 15.
    return 15;
}

sub get_max {
    # (self) : integer
    # Returns 500.
    return 500;
}

sub get_min {
    # (self) : int
    # Returns 5.
    return 5;
}

1;
