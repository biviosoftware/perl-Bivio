# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::PrimaryIdArray;
use strict;
use Bivio::Base 'Type.ArrayBase';

my($_UT) = b_use('Type.PrimaryId');

sub UNDERLYING_TYPE {
    return $_UT;
}

1;
