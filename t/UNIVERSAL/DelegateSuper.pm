# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::UNIVERSAL::DelegateSuper;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';


sub as_string {
    my(undef, $delegator) = shift->delegated_args(@_);
    return $delegator->simple_package_name;
}

1;
