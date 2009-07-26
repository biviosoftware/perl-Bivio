# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::t::Shell::T1;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub handle_autoload {
    return shift->m1(@_);
}

sub m1 {
    shift;
    return shift;
}

1;
