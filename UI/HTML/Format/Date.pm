# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format::Date;
use strict;
$Bivio::UI::HTML::Format::Date::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Format::Date - transforms a unix time to date/time string

=head1 SYNOPSIS

    use Bivio::UI::HTML::Format::Date;
    Bivio::UI::HTML::Format::Date->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Format> formats a unix time into a date string.

=cut

use Bivio::UI::HTML::Format;
@Bivio::UI::HTML::Format::Date::ISA = ('Bivio::UI::HTML::Format');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Format::Date>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="get_widget_value"></a>

=head2 static get_widget_value(int time) : string

Formats a date time value as a string with a 4 digit year.

=head2 static get_widget_value(int time, int year_digits) : string

Formats a date time value as a string with the specified 2 or 4 digit year.

=cut

sub get_widget_value {
    my(undef, $time, $year_digits) = @_;
    die("invalid year_digits $year_digits") if (defined($year_digits)
	    && $year_digits != 2 && $year_digits != 4);
    my($sec, $min, $hour, $mday, $mon, $year) = localtime($time);
    return $year_digits == 2
	    ? sprintf('%02d/%02d/%02d', $mon + 1, $mday, $year =~ /(\d\d)$/)
	    : sprintf('%02d/%02d/%04d', $mon + 1, $mday, $year + 1900);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
