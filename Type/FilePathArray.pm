# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FilePathArray;
use strict;
use Bivio::Base 'Type.SemicolonStringArray';

my($_FP) = b_use('Type.FilePath');

sub UNDERLYING_TYPE {
    return $_FP;
}

1;
