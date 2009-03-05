# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FilePathArray;
use strict;
use Bivio::Base 'Type.StringArray';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = b_use('Type.FilePath');

sub LITERAL_SEPARATOR {
    return '; ';
}

sub LITERAL_SEPARATOR_REGEX {
    return qr{\s*;\s*}s;
}

sub UNDERLYING_TYPE {
    return $_FP;
}

sub from_literal_validator {
    shift;
    return $_FP->from_literal(@_);
}

1;
