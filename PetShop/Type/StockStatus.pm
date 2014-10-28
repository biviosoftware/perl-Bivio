# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::StockStatus;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => [0],
    NOT_IN_STOCK => [1],
    IN_STOCK => [2],
]);

1;
