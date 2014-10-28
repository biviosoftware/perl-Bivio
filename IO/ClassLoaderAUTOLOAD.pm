# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::IO::ClassLoaderAUTOLOAD;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';

our($AUTOLOAD);
my($_CL) = b_use('IO.ClassLoader');

sub AUTOLOAD {
    return $_CL->call_autoload($AUTOLOAD, \@_);
}

sub handle_class_loader_require {
    my($proto, $pkg) = @_;
    ($pkg || $proto->my_caller)->replace_subroutine(AUTOLOAD => \&AUTOLOAD);
    return;
}

sub import {
    return shift->handle_class_loader_require((caller())[0]);
}

1;
