# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::SemicolonStringArray;
use strict;
use Bivio::Base 'Type.StringArray';


sub LITERAL_SEPARATOR {
    return '; ';
}

sub LITERAL_SEPARATOR_REGEX {
    return qr{\s*;\s*}s;
}

1;
