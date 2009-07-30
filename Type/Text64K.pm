# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::Text64K;
use strict;
use Bivio::Base 'Type.Text';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_width {
    # Returns 64K - 1 so length fits in two bytes.
    return 0xffff;
}

1;
