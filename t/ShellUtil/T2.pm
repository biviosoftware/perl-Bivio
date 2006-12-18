# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::ShellUtil::T2;
use strict;
use base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub my_package {
    return shift->simple_package_name . "\n";
}

1;
