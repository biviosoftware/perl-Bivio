# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::OTPSeed;
use strict;
use Bivio::Base 'Type.SyntacticString';


sub REGEX {
    return qr{[0-9a-z]{8}};
}

sub generate {
    return shift->use('Bivio::Biz::Random')->string(8, [0..9, 'a'..'z']);
}

sub get_width {
    return 16;
}

sub internal_post_from_literal {
    return lc($_[1]);
}

1;
