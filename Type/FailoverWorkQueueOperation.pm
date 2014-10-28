# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FailoverWorkQueueOperation;
use strict;
use base 'Bivio::Type::EnumDelegator';


__PACKAGE__->compile;

sub is_continuous {
    return 0;
}

1;
