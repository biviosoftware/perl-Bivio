# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Base;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::IO::ClassLoader;
use Bivio::Die;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub import {
    my($first, $map_or_class) = @_;
    Bivio::Die->die('must specify class or map on "use Bivio::Base" line')
        unless $map_or_class;
    my($pkg) = (caller(0))[0];
    Bivio::Die->eval_or_die(
        "package $pkg; use base '"
	. Bivio::IO::ClassLoader->map_require(
	    $map_or_class =~ /\W/ ? $map_or_class
	        :  Bivio::IO::ClassLoader->after_in_map($map_or_class, $pkg)
	) . "';1",
    );
    return;
}

1;
