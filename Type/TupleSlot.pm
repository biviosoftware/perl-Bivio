# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TupleSlot;
use strict;
use Bivio::Base 'Type.Line';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WIDTH) = b_use('Type.Text64K')->get_width;

sub compare_defined {
    return shift->SUPER::compare_defined(map(lc($_), @_));
}

sub get_width {
    return $_WIDTH;
}

1;
