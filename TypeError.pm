# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::TypeError;
use strict;
use Bivio::Base 'Bivio::Type::Enum';

# C<Bivio::TypeError>

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile(
	Bivio::IO::ClassLoader->delegate_require_info(__PACKAGE__));

sub is_continuous {
    # (proto) : false
    # Task Ids aren't continuous.  Tasks can go away.
    return 0;
}

1;
