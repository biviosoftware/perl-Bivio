# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::BooleanFalseDefault;
use strict;
use Bivio::Base 'Type.Boolean';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_default {
    return 0;
}

1;
