# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::USZipCode5;
use strict;
use Bivio::Base 'Type.USZipCode';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_min_width {
    return 5;
}

sub get_width {
    return 5;
}

1;
