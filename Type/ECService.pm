# Copyright (c) 2002-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::ECService;
use strict;
use Bivio::Base 'Type.EnumDelegator';

__PACKAGE__->compile;

sub is_continuous {
    return 0;
}

1;
