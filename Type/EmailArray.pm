# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::EmailArray;
use strict;
use Bivio::Base 'Type.StringArray';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_E) = __PACKAGE__->use('Type.Email');

sub UNDERLYING_TYPE {
    return $_E;
}

sub get_width {
    return 1000;
}

1;
