# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::CRMThreadStatus;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

__PACKAGE__->compile([
    UNKNOWN => 0,
    # Alphabetical to get around sorting bug
    CLOSED => 1,
    LOCKED => 2,
    NEW => 3,
    OPEN => 4,
]);

1;
