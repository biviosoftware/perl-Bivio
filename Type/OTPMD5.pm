# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::OTPMD5;
use strict;
use Bivio::Base 'Type.SyntacticString';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REGEX {
    return qr{[0-9a-f]{16}}i;
}

sub get_width {
    return 16;
}

sub internal_post_from_literal {
    return uc($_[1]);
}

1;
