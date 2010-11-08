# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FolderArg;
use strict;
use Bivio::Base 'Type.String';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WIDTH) = b_use('Type.FilePath')->get_width;

sub get_width {
    return $_WIDTH;
}

1;
