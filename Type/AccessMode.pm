# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::AccessMode;
use strict;
use base 'Bivio::Type::Enum';


__PACKAGE__->compile_with_numbers([qw(PUBLIC PRIVATE)]);

1;
