# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::TypeError;
use strict;
# Do not use Bivio::Base
use base 'Bivio::Type::Enum';

__PACKAGE__->compile(
    Bivio::IO::ClassLoader->delegate_require(__PACKAGE__)->get_delegate_info);

sub is_continuous {
    return 0;
}

1;
