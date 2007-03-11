# Copyright (c) 2004-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::t::EnumDelegator::I1;
use strict;
use Bivio::Base 'Bivio::Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    my($proto) = @_;
    return [
	N1 => [1],
    ];
}

sub inc_value {
    return shift->as_int + shift;
}

sub static_exists {
    return shift->package_name;
}

1;
