# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format::DateTime;
use strict;
$Bivio::UI::HTML::Format::DateTime::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Format::DateTime - transforms a unix time to date/time string

=head1 SYNOPSIS

    use Bivio::UI::HTML::Format::DateTime;
    Bivio::UI::HTML::Format::DateTime->get_widget_value($time);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Format>

=cut

use Bivio::UI::HTML::Format;
@Bivio::UI::HTML::Format::DateTime::ISA = ('Bivio::UI::HTML::Format');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Format::DateTime> formats a unix time into
a date/time string.  May consult user preferences.

=cut

#=IMPORTS
use Bivio::Type::DateTime;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_widget_value"></a>

=head2 static get_widget_value(string time) : string

=head2 static get_widget_value(string time, Bivio::UI::DateTimeMode mode) : string

Formats a date/time value as a string.

May pass string for I<mode> and it will be interpreted
as a L<Bivio::UI::DateTimeMode|Bivio::UI::DateTimeMode>.

=cut

sub get_widget_value {
    my(undef, $time, $mode) = @_;
    return '' unless defined($time);
    my($sec, $min, $hour, $mday, $mon, $year)
	    = Bivio::Type::DateTime->to_parts($time);
    my($m) = Bivio::UI::DateTimeMode->from_any(
	    $mode || 'DATE_TIME')->as_int;
    # ASSUMES: Bivio::UI::DateTimeMode is DATE=1, TIME=2 & DATE_TIME=3
    return (($m & 1) ? sprintf('%02d/%02d/%04d', $mon, $mday, $year) : '')
	    .($m == 3 ? ' ' : '')
	    .(($m & 2) ? sprintf('%02d:%02d:%02d', $hour, $min, $sec) : '')
	    # This is even correct if just a time, no?
	    .' GMT';
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
