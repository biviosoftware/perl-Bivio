# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FileArg;
use strict;
use Bivio::Base 'Type.FileField';


sub from_literal {
    return shift->unsafe_from_disk(@_);
}

1;
