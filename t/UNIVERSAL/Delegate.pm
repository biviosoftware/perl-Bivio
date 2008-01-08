# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::UNIVERSAL::Delegate;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub echo {
    my($delegator, $arg) = shift->delegated_args(@_);
    return $delegator->simple_package_name . " $arg";
}

1;
