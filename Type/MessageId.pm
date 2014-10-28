# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::MessageId;
use strict;
use Bivio::Base 'Type.SyntacticString';


sub REGEX {
    return qr{[^<>]+\@[^<>]+};
}

sub get_width {
    return 255;
}

1;
