# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::OTP::Type::OTPSeed;
use strict;
use Bivio::Base 'Type.SyntacticString';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REGEX {
    return qr{[0-9a-z]{8}};
}

sub get_width {
    return 16;
}

sub internal_post_from_literal {
    return lc($_[1]);
}

1;
