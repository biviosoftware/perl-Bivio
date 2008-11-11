# Copyright (c) 2001-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::UNIVERSAL::Delegate;
use strict;
use Bivio::Base 'Bivio::t::UNIVERSAL::DelegateSuper';
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub echo {
    my(undef, $delegator, $arg) = shift->delegated_args(@_);
    return Bivio::IO::Alert->format_args(
	$delegator->simple_package_name,
	' ',
	$arg,
    );
}

1;
