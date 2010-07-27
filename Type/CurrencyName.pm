# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::CurrencyName;
use strict;
use Bivio::Base 'Type.SyntacticString';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REGEX {
    return qr{[a-z]{3}}i;
}

sub get_default {
    return 'USD';
}

sub get_width {
    return 3;
}

sub internal_post_from_literal {
    return uc($_[1]);
}

1;
