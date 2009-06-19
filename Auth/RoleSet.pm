# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::RoleSet;
use strict;
use Bivio::Base 'Type.EnumSet';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = b_use('Auth.Role');
__PACKAGE__->initialize;

sub get_enum_type {
    return $_R;
}

sub get_width {
    return 15;
}

1;
