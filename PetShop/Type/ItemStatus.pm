# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::ItemStatus;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => [0],
    OK => [1, 'OK'],
    DAMAGED => [2],
]);

1;
