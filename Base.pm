# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Base;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::IO::ClassLoader;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub import {
    my($first, $class) = @_;
    Bivio::Die->eval_or_die(
	'package ' . (caller(0))[0] . ";use base '"
	. __PACKAGE__->use($class || 'Bivio::UNIVERSAL')
        . "';1",
    );
    return shift->SUPER::import($first);
}

1;
