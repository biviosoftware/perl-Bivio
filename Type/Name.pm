# Copyright (c) 1999-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Name;
use strict;
use Bivio::Base 'Type.Line';

# C<Bivio::Type::Name> defines a simple name, e.g. first name,
# last name, account identifier, and login name.  If you want
# a compound name, use L<Bivio::Type::Line|Bivio::Type::Line>.


sub get_width {
    return 30;
}

1;
