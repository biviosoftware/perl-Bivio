# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TupleSlotLabelArray;
use strict;
use Bivio::Base 'Type.SemicolonStringArray';

my($_TSL) = b_use('Type.TupleSlotLabel');

sub UNDERLYING_TYPE {
    return $_TSL;
}

1;
