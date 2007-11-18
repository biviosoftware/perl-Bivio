# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::GeomNumber;
use strict;
use Bivio::Base 'Bivio::Type';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub from_literal {
    my($proto, $value) = @_;
    return (undef, undef)
	unless defined($value) && length($value);
    return (undef, Bivio::TypeError->SYNTAX_ERROR)
	unless $value =~ /^[+-]?(?=\d|\.\d)\d*(?:\.\d*)?(?:[Ee]([+-]?\d+))?$/;
    return $value + 0;
}

1;
