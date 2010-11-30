# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::ECService;
use strict;
use Bivio::Base 'Bivio::Type::EnumDelegator';

# C<Bivio::Type::ECService>

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile;

sub is_continuous {
    return 0;
}

1;
