# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::UNIVERSAL::Delegate;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub as_string {
    return shift->simple_package_name;
}

sub echo {
    my($delegator, $arg) = shift->delegated_args(@_);
    return Bivio::IO::Alert->format_args(
	$delegator->simple_package_name,
	' ',
	$arg,
    );
}

sub simple_package_name {
    my($delegator) = shift->delegated_args(@_);
    return $delegator->call_super(
	$delegator->delegated_package, 'simple_package_name');
}

1;
