# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::PositiveInteger;
use strict;
use Bivio::Base 'Type.Integer';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_min {
    return 1;
}

1;
