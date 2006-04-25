# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::IO::t::ClassLoader::SyntaxError;
use strict;
use base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub some_sub {
    return;
}

sub some_other_sub {
}

syntax error;

1;
