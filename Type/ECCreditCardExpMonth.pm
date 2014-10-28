# Copyright (c) 2000-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECCreditCardExpMonth;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    JANUARY => [1, '01'],
    FEBRUARY => [2, '02'],
    MARCH => [3, '03'],
    APRIL => [4, '04'],
    MAY => [5, '05'],
    JUNE => [6, '06'],
    JULY => [7, '07'],
    AUGUST => [8, '08'],
    SEPTEMBER => [9, '09'],
    OCTOBER => [10, '10'],
    NOVEMBER => [11, '11'],
    DECEMBER => [12, '12'],
]);

1;
