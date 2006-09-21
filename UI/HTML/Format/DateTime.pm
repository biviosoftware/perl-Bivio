# Copyright (c) 1999-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Format::DateTime;
use strict;
use base 'Bivio::UI::HTML::Format';
use Bivio::Type::DateTime;
use Bivio::UI::DateTimeMode;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MONTHS) = [qw(
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
)];
my($_DT) = Bivio::Type->get_instance('DateTime');

sub get_widget_value {
    my(undef, $time, $mode, $no_timezone) = @_;
    return ''
	unless defined($time);
    $mode = defined($mode) ? Bivio::UI::DateTimeMode->from_any($mode)
	: Bivio::UI::DateTimeMode->get_default;
    return $_DT->rfc822($time)
	if $mode->eq_rfc822;
    my($sec, $min, $hour, $mday, $mon, $year) = $_DT->to_parts($time);
    my($m) = $mode->as_int;
    # ASSUMES: Bivio::UI::DateTimeMode is DATE=1, TIME=2 & DATE_TIME=3
    return (
	$m <= 3 ? (
	    (($m & 1) ? sprintf('%02d/%02d/%04d', $mon, $mday, $year) : '')
	    . ($m == 3 ? ' ' : '')
	    . (($m & 2) ? sprintf('%02d:%02d:%02d', $hour, $min, $sec) : '')
        ) : $mode->eq_month_name_and_day_number ? "$_MONTHS->[$mon] $mday"
	: $mode->eq_full_month_day_and_year_uc
	    ? uc($_MONTHS->[$mon]) . " $mday, $year"
	: $mode->eq_full_month_and_year_uc ? uc($_MONTHS->[$mon]) . ", $year"
	: $mode->eq_full_month ? $_MONTHS->[$mon]
	: $mode->eq_month_and_day ? sprintf('%02d/%02d', $mon, $mday)
	: $mode->eq_day_month3_year
	    ? sprintf('%02d-%.3s-%04d', $mday, $_MONTHS->[$mon], $year)
	: $mode->eq_day_month3_year_time
	    ? sprintf('%02d-%.3s-%04d %02d:%02d:%02d',
		      $mday, $_MONTHS->[$mon], $year, $hour, $min, $sec)
	: $mode->eq_day_month3_year_time_period
	    ? sprintf('%02d-%.3s-%04d %02d:%02d:%02d %.2s',
		      $mday, $_MONTHS->[$mon], $year,
		      _to_twelve_hour($hour), $min, $sec, _period($hour))
        : Bivio::Die->throw_die('DIE', {
	    message => 'unhandled DateTimeMode',
	    entity => $mode
	})) . ($no_timezone ? '': ' GMT');
}

sub _period {
    my($hour) = @_;
    return $hour > 11 && $hour < 24 ? 'PM' : 'AM';
}

sub _to_twelve_hour {
    my($hour) = @_;
    return $hour > 0 && $hour < 13 ? $hour
	: $hour == 0 ? 12
	    : $hour - 12;
}

1;
