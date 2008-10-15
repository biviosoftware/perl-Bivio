# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::Month;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    JANUARY => [1, 'Jan', 'January', '01'],
    FEBRUARY => [2, 'Feb', 'February', '02'],
    MARCH => [3, 'Mar', 'March', '03'],
    APRIL => [4, 'Apr', 'April', '04'],
    MAY => [5, 'May', 'May', '05'],
    JUNE => [6, 'Jun', 'June', '06'],
    JULY => [7, 'Jul', 'July', '07'],
    AUGUST => [8, 'Aug', 'August', '08'],
    SEPTEMBER => [9, 'Sep', 'September', '09'],
    OCTOBER => [10, 'Oct', 'October'],
    NOVEMBER => [11, 'Nov', 'November'],
    DECEMBER => [12, 'Dec', 'December'],
]);


sub get_two_digit_value {
    my($self) = @_;
    return sprintf("%.2d", $self->as_int);
}

1;
