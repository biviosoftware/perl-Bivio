# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::ImageFileName;
use strict;
use Bivio::Base 'Type.DocletFileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ERROR {
    return Bivio::TypeError->FILE_NAME;
}

sub PRIVATE_FOLDER {
    return shift->IMAGE_FOLDER;
}

sub REGEX {
    return qr{[-\w]+.\w{2,4}$};
}

sub get_width {
    return 50;
}

1;
