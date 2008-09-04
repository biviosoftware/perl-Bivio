# Copyright (c) 2001 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::Type::ECPaymentStatusSet;
use strict;
use Bivio::Base 'Type.EnumSet';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_ECPS) = b_use('Type.ECPaymentStatus');
__PACKAGE__->initialize;

sub get_enum_type {
    return $_ECPS
}

sub get_width {
    return 4;
}

1;
