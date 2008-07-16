# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::ShellUtil::T2;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub my_package {
    return shift->simple_package_name . "\n";
}

sub f2_USAGE {'x -- something wonderful'}
sub f2 {
    my($x) = @_;
    return $x x 2;
}

sub f1 {
    return;
}

1;
