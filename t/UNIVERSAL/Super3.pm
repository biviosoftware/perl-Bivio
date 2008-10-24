# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::UNIVERSAL::Super3;
use strict;
use Bivio::Base 'Bivio::t::UNIVERSAL::Super2';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub s1 {
    return 'Super3';
}

1;
