# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format::DateTime;
use strict;
$Bivio::UI::HTML::Format::DateTime::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Format::DateTime::VERSION;

=head1 NAME

Bivio::UI::HTML::Format::DateTime - transforms a DateTime to date/time string

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

C<Bivio::UI::HTML::Format::DateTime> formats a DateTime value
to a date, time, or date and time string.

=cut

#=IMPORTS
use Bivio::Type::DateTime;
use Bivio::UI::DateTimeMode;

#=VARIABLES
my(@_MONTH_NAMES) = qw(
    N/A
    January
    February
    March
    April
    May
    June
    July
    August
    September
    October
    November
    December
);

=head1 METHODS

=cut

=for html <a name="get_widget_value"></a>

=head2 static get_widget_value(string time) : string

=head2 static get_widget_value(string time, Bivio::UI::DateTimeMode mode) : string

=head2 static get_widget_value(string time, Bivio::UI::DateTimeMode mode, boolean no_timezone) : string

Formats a date/time value as a string.  Unless I<no_timezone> is set,
the timezone GMT will be appended.

May pass string for I<mode> and it will be interpreted
as a L<Bivio::UI::DateTimeMode|Bivio::UI::DateTimeMode>.

=cut

sub get_widget_value {
    my(undef, $time, $mode, $no_timezone) = @_;
    return '' unless defined($time);
    my($sec, $min, $hour, $mday, $mon, $year)
	    = Bivio::Type::DateTime->to_parts($time);
    $mode = Bivio::UI::DateTimeMode->from_any($mode || 'DATE_TIME');
    my($m) = $mode->as_int;
    # ASSUMES: Bivio::UI::DateTimeMode is DATE=1, TIME=2 & DATE_TIME=3
    return (($m & 1) ? sprintf('%02d/%02d/%04d', $mon, $mday, $year) : '')
	    .($m == 3 ? ' ' : '')
	    .(($m & 2) ? sprintf('%02d:%02d:%02d', $hour, $min, $sec) : '')
	    # This is even correct if just a time, no?
	    .($no_timezone ? '': ' GMT') if $m <= 3;
    return $_MONTH_NAMES[$mon].' '.$mday.($no_timezone ? '': ' GMT')
	    if $mode == Bivio::UI::DateTimeMode::MONTH_NAME_AND_DAY_NUMBER();
    return sprintf('%02d/%02d', $mon, $mday).($no_timezone ? '': ' GMT')
	    if $mode == Bivio::UI::DateTimeMode::MONTH_AND_DAY();
    Bivio::Die->throw_die('DIE', {
	message => 'unknown DateTimeMode',
	entity => $mode
    });
    # DOES NOT RETURN
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
