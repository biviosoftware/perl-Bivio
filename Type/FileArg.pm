# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FileArg;
use strict;
use Bivio::Base 'Type.FileField';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub from_literal {
    return shift->unsafe_from_disk(@_);
}

1;
