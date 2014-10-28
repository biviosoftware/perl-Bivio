# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::Appellation;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => [0, 'None'],
    DR => [1, 'Dr.'],
    MR => [2, 'Mr.'],
    MRS => [3, 'Mrs.'],
    MS => [4, 'Ms.'],
]);

1;
