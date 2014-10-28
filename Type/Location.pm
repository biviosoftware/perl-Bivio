# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Location;
use strict;
use Bivio::Base 'Type.EnumDelegator';

__PACKAGE__->compile;

sub first_alternative_location {
    return shift->from_int(2);
}

sub get_default {
    return shift->from_int(1);
}

1;
