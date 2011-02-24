# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::BooleanTrueDefault;
use strict;
use Bivio::Base 'Type.Boolean';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_default {
    return 1;
}

1;
