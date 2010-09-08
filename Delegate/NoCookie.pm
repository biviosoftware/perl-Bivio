# Copyright (c) 2001-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::NoCookie;
use strict;
use Bivio::Base 'Bivio::Collection::Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub assert_is_ok {
    return 1;
}

sub header_out {
    return;
}

1;
