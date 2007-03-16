# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::MotionVote;
use strict;
use base 'Bivio::Type::EnumDelegator';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

__PACKAGE__->compile;

sub is_continuous {
    return 0;
}

1;
