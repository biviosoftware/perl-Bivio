# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FolderArg;
use strict;
use Bivio::Base 'Type.String';

my($_WIDTH) = b_use('Type.FilePath')->get_width;

sub get_width {
    return $_WIDTH;
}

1;
