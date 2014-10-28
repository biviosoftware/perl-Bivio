# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::EmailArray;
use strict;
use Bivio::Base 'Type.StringArray';

my($_E) = b_use('Type.Email');

sub UNDERLYING_TYPE {
    return $_E;
}

sub get_width {
    return 1000;
}

1;
