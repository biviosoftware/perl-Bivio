# Copyright (c) 1999-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Country;
use strict;
use Bivio::Base 'Type.String';


sub from_literal {
    my($proto) = shift;
    my($value, $err) = $proto->SUPER::from_literal(@_);
    return ($value, $err)
        unless defined($value);
    return (undef, Bivio::TypeError->COUNTRY)
        unless $value =~ /^[a-z]+$/i && $proto->get_width == length($value);
    return uc($value);
}

sub get_width {
    return 2;
}

1;
