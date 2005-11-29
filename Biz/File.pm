# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::File;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::IO::Config;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
Bivio::IO::Config->register(my $_CFG = {
    root => Bivio::IO::Config->REQUIRED,
});

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub absolute_path {
    my(undef, $base) = @_;
    return "$_CFG->{root}/$base";
}

1;
