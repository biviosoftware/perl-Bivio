# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Text;
use strict;
use Bivio::Base 'Type.Line';
use Bivio::TypeError;

# C<Bivio::Type::Text> defines a complex text string to be stored
# in the database, e.g. a remark or a URL.  This is the "maximum"
# size string we allow in the database for our purposes.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_width {
    # : int
    # Returns 500.
    return 500;
}

1;
