# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::MACAddress;
use strict;
use Bivio::Base 'Type.SyntacticString';


sub REGEX {
    return qr{(?:[0-9a-f]{2}\:){5}[0-9a-f]{2}}i;
}

sub get_width {
    return 17;
}

sub internal_post_from_literal {
    return lc($_[1]);
}

1;
