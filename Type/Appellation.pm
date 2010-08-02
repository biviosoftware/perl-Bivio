# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::Appellation;
use strict;
use Bivio::Base 'Bivio::Type::Enum';

# C<Bivio::Type::Appellation>

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    UNKNOWN => [0, 'None'],
    DR => [1, 'Dr.'],
    MR => [2, 'Mr.'],
    MRS => [3, 'Mrs.'],
    MS => [4, 'Ms.'],
]);

1;
