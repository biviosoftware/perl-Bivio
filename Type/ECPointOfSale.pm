# Copyright (c) 2002-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::ECPointOfSale;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => [0],
    PHONE => [1],
    INTERNET => [2],
    MAIL => [3],
    IN_PERSON => [4],
]);

1;
