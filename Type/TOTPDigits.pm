# Copyright (c) 2025 bivio, Inc.  All rights reserved.
package Bivio::Type::TOTPDigits;
use strict;
use Bivio::Base 'Type.Integer';

my($_TE) = b_use('Bivio.TypeError');

sub from_literal {
    my($proto, $value) = @_;
    return (undef, $_TE->NULL)
        unless defined($value);
    return (undef, $_TE->SYNTAX_ERROR)
        unless $value == 6 || $value == 8;
    return $value;
}

1;
