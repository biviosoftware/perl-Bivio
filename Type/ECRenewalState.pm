# Copyright (c) 2002-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::ECRenewalState;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => [0],
    OK => [1],
    FIRST_NOTICE => [2],
    SECOND_NOTICE => [3],
    EXPIRED => [4],
]);

1;
