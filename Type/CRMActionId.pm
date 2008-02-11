# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::CRMActionId;
use strict;
use Bivio::Base 'Type.Number';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PI) = __PACKAGE__->use('Type.PrimaryId');

sub get_decimals {
    return 0;
}

sub get_max {
    return $_PI->get_max;
}

sub get_min {
    return -100;
}

sub get_precision {
    return $_PI->get_precision;
}

sub get_width {
    return $_PI->get_width;
}

1;
