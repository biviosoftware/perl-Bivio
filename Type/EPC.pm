# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::EPC;
use strict;
use Bivio::Base 'Type.SyntacticString';


sub REGEX {
    return qr{[0-9a-f]{24}}i;
}

sub get_width {
    return 24;
}

sub internal_post_from_literal {
    return uc($_[1]);
}

1;
