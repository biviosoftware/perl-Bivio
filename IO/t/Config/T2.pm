# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::IO::t::Config::T2;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    a => $_C->REQUIRED,
});

sub handle_config {
}

1;
