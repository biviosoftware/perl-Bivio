# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::NonNegativePercent;
use strict;
use Bivio::Base 'Type.Percent';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub can_be_negative {
    return 0;
}

sub get_min {
    return 0;
}

1;
