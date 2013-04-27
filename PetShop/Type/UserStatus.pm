# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::UserStatus;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    UNKNOWN => [0],
    CUSTOMER => [1],
    GOLD_CUSTOMER => [2],
]);

1;
