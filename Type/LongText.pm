# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::LongText;
use strict;
use Bivio::Base 'Bivio::Type::Text';

# C<Bivio::Type::LongText> same as L<Bivio::Type::Text|Bivio::Type::Text>
# except 4000 characters.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_width {
    # : int
    # Returns 4000.
    return 4000;
}

1;
