# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::USState;
use strict;
use Bivio::Base 'Type.SyntacticString';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REGEX {
    return qr{[a-z]{2}}i;
}

sub get_width {
    return 2;
}

sub internal_post_from_literal {
    return uc($_[1]);
}

1;
