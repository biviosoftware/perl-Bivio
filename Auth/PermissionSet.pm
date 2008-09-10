# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::PermissionSet;
use strict;
use Bivio::Base 'Type.EnumSet';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_P) = b_use('Auth.Permission');
__PACKAGE__->initialize();

sub get_enum_type {
    return $_P;
}

sub get_width {
    return 15;
}

1;
