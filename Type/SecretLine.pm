# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::SecretLine;
use strict;
use Bivio::Base 'Type.Secret';

my($_L) = __PACKAGE__->use('Type.Line');

sub from_literal {
    shift;
    return $_L->from_literal(@_);
}

sub get_width {
    return 500;
}

1;
