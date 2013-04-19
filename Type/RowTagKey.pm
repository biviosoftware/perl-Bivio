# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::RowTagKey;
use strict;
use Bivio::Base 'Type.EnumDelegator';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile();

sub get_type {
    return b_use('Type', shift->internal_get_type);
}

sub is_continuous {
    return 0;
}

1;
