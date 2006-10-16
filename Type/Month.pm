# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::Month;
use strict;
$Bivio::Type::Month::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Month::VERSION;

=head1 NAME

Bivio::Type::Month - enumerated months

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::Month;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::Month::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::Month>

=cut

#=IMPORTS

#=VARIABLES
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


=head1 METHODS

=cut

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
