# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Unit::t::Unit::T1;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';


sub echo {
    return $_[1];
}

sub method1 {
    shift;
    return @_;
}

sub method2 {
    shift;
    return @_;
}

sub method3 {
    b_die(\@_, ': should not be called');
    # DOES NOT RETURN
}

1;
