# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::Role;
use strict;
use Bivio::Base 'Type.EnumDelegator';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile;

sub get_overlap_count {
    return int(shift->get_non_zero_list / 2);
}

sub is_continuous {
    return 0;
}

1;
