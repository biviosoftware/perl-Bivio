# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
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
    JANUARY => [1, 'Jan', 'January'],
    FEBRUARY => [2, 'Feb', 'February'],
    MARCH => [3, 'Mar', 'March'],
    APRIL => [4, 'Apr', 'April'],
    MAY => [5],
    JUNE => [6, 'Jun', 'June'],
    JULY => [7, 'Jul', 'July'],
    AUGUST => [8, 'Aug', 'August'],
    SEPTEMBER => [9, 'Sep', 'September'],
    OCTOBER => [10, 'Oct', 'October'],
    NOVEMBER => [11, 'Nov', 'November'],
    DECEMBER => [12, 'Dec', 'December'],
]);


=head1 METHODS

=cut

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
