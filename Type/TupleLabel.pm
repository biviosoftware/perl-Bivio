# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TupleLabel;
use strict;
use Bivio::Base 'Type.SyntacticString';


sub REGEX {
    return qr{[a-z][-\w]+}i;
}

sub compare_defined {
    my(undef, $left, $right) = @_;
    return lc($left) cmp lc($right);
}

1;
