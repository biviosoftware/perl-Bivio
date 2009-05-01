# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TupleLabel;
use strict;
use Bivio::Base 'Type.SyntacticString';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REGEX {
    return qr{[a-z][-\w]+}i;
}

sub compare_defined {
    my(undef, $left, $right) = @_;
    return lc($left) cmp lc($right);
}

1;
