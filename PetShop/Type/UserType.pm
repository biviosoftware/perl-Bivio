# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::UserType;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => [0],
    HOME_CONSUMER => [1],
    COMMERCIAL_BUSINESS => [2],
    WHOLE_SELLER => [3],
]);

1;
