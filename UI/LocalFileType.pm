# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::LocalFileType;
use strict;
use Bivio::Base 'Type.Enum';
__PACKAGE__->compile([
    PLAIN => [1, 'plain/'],
    VIEW => [2, 'view/'],
    DDL => [5, 'ddl/'],
]);

sub get_path {
    return shift->get_short_desc;
}

sub is_continuous {
    return 0;
}

1;
