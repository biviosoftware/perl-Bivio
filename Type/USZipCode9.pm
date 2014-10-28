# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::USZipCode9;
use strict;
use Bivio::Base 'Type.USZipCode';


sub REGEX {
    return qr{(\d{9})};
}

sub SYNTAX_ERROR {
    return Bivio::TypeError->US_ZIP_CODE_9;
}

sub TOO_SHORT_ERROR {
    return shift->SYNTAX_ERROR;
}

sub get_min_width {
    return 9;
}

sub to_html {
    my(undef, $value) = @_;
    substr($value, 5, 0) = '-';
    return $value;
}

1;
