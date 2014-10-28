# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::BunitEnum;
use strict;
use Bivio::Base 'Type.Enum';
b_use('IO.ClassLoaderAUTOLOAD');

__PACKAGE__->compile([
    UNKNOWN => 0,
    NAME1 => 1,
    NAME2 => 2,
]);

1;
