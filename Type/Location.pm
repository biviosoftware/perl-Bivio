# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Location;
use strict;
use Bivio::Base 'Bivio::Type::Enum';

# C<Bivio::Type::Location> describes the physical location where an
# address, phone, or email resides.
#
# It can be assumed C<HOME> is defined.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile(
    Bivio::IO::ClassLoader->delegate_require_info(__PACKAGE__));

sub get_default {
    return shift->from_int(1);
}

#=PRIVATE METHODS

1;
