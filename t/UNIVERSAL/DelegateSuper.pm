# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::UNIVERSAL::DelegateSuper;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub as_string {
    my(undef, $delegator) = shift->delegated_args(@_);
    return $delegator->simple_package_name;
}

sub simple_package_name {
    my($delegation, $delegator) = shift->delegated_args(@_);
    return $delegation->call_delegator_super('simple_package_name');
}

1;
