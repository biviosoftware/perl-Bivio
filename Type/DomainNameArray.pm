# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::DomainNameArray;
use strict;
use Bivio::Base 'Type.StringArray';
b_use('IO.ClassLoaderAUTOLOAD');


sub ANY_SEPARATOR_REGEX {
    return shift->LITERAL_SEPARATOR_REGEX;
}

sub LITERAL_SEPARATOR_REGEX {
    return qr{\s*,\s*|\s+};
}

sub UNDERLYING_TYPE {
    return Type_DomainName();
}

sub get_width {
    return Type_DomainName()->get_width * 10;
}

1;
