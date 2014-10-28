# Copyright (c) 2001 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::Type::ECPaymentStatusSet;
use strict;
use Bivio::Base 'Type.EnumSet';

my($_ECPS) = b_use('Type.ECPaymentStatus');
__PACKAGE__->initialize;

sub get_enum_type {
    return $_ECPS
}

sub get_width {
    return 4;
}

1;
