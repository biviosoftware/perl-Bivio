# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::IO::t::Config::T1;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = __PACKAGE__->use('IO.Config');
Bivio::IO::Config->register(my $_CFG = {
    n2 => {
	a => 2,
    },
    Bivio::IO::Config->NAMED => {
       a => 0,
    },
});

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub unsafe_config {
    shift;
    return $_C->unsafe_get(@_);
}

1;
