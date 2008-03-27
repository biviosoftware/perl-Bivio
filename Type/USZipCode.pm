# Copyright (c) 2002-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::USZipCode;
use strict;
use Bivio::Base 'Type.SyntacticString';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REGEX {
    return qr{(\d{5}(?:\d{4})?)};
}

sub SYNTAX_ERROR {
    return Bivio::TypeError->US_ZIP_CODE;
}

sub internal_pre_from_literal {
    my($proto, $value) = @_;
    $value =~ s/[-\s]+//g;
    return $value;
}

1;
