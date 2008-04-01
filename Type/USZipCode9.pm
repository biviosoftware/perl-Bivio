# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::USZipCode9;
use strict;
use Bivio::Base 'Type.USZipCode';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub TOO_SHORT_ERROR {
    return Bivio::TypeError->US_ZIP_CODE_9;
}

sub get_min_width {
    return 9;
}

sub get_width {
    return 10;
}

sub to_html {
    my(undef, $value) = @_;
    substr($value, 5, 0) = '-';
    return $value;
}

1;
