# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::DateTimeMode;
use strict;
$Bivio::UI::DateTimeMode::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::DateTimeMode::VERSION;

=head1 NAME

Bivio::UI::DateTimeMode - list of display modes for date times

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::DateTimeMode;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::UI::DateTimeMode::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::UI::DateTimeMode> are the different modes which
L<Bivio::UI::HTML::Widget::DateTime|Bivio::UI::HTML::Widget::DateTime>
operates in.

The values are:

=over 4

=item DATE

displays the date only.

=item TIME

displays the time only.

=item DATE_TIME

displays the date and time.

=item MONTH_NAME_AND_DAY_NUMBER

displays a long month name and day number, e.g. October 31

=item MONTH_AND_DAY

displays month/day.

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    # DO NOT CHANGE THESE NUMBERS
    # unless you modify UI::Widget::HTML::DateTime
    DATE => [1],
    TIME => [2],
    DATE_TIME => [3],
    MONTH_NAME_AND_DAY_NUMBER => [4],
    MONTH_AND_DAY => [5],
]);

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
