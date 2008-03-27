# Copyright (c) 2002-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::DomainName;
use strict;
use Bivio::Base 'Type.SyntacticString';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REGEX {
    return qr/((?:[-a-z0-9]{1,63})(?:\.[-a-z0-9]{1,63})+)/is;
}

sub SYNTAX_ERROR {
    return Bivio::TypeError->DOMAIN_NAME;
}

sub get_width {
    return 255.
}

sub internal_post_from_literal {
    return lc($_[1]);
}

1;
