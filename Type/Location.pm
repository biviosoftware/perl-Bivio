# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Location;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile(
    b_use('IO.ClassLoader')->delegate_require_info(__PACKAGE__));

sub get_default {
    return shift->from_int(1);
}

1;
