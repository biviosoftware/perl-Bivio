# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::TypeError;
use strict;
# Do not use Bivio::Base
use base 'Bivio::Type::Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile(
    Bivio::IO::ClassLoader->delegate_require_info(__PACKAGE__));

sub is_continuous {
    return 0;
}

1;
