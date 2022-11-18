# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Line;
use strict;
use Bivio::Base 'Type.String';


sub from_literal {
    my($proto, $value) = @_;
    $value = ${$proto->canonicalize_charset($value)}
        if defined($value);
    return $proto->SUPER::from_literal($value);
}

sub get_width {
    return 100;
}

1;
