# Copyright (c) 1999-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Format::DateTime;
use strict;
use Bivio::Base 'UIHTML.Format';

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
my($_DT) = b_use('Type.DateTime');
my($_DTM) = b_use('UI.DateTimeMode');

sub get_widget_value {
    my(undef, $dt, $mode, $no_timezone) = @_;
    return ''
	unless defined($dt);
    $mode = defined($mode) ? $_DTM->from_any($mode) : $_DTM->get_default;
    my($op) = '_to_' . lc($mode->get_name);
    return (\&{$op})->($_DT->to_parts($dt), $dt)
	. ($no_timezone || $op eq '_to_rfc822' ? '' : ' GMT');
}

sub _am_pm {
    my($hour) = @_;
    return $hour > 11 && $hour < 24 ? 'PM' : 'AM';
}

sub _to_date {
    my($sec, $min, $hour, $mday, $mon, $year, $dt) = @_;
    return sprintf('%02d/%02d/%04d', $mon, $mday, $year);
}

sub _to_date_time {
    my($sec, $min, $hour, $mday, $mon, $year, $dt) = @_;
    return sprintf('%02d/%02d/%04d %02d:%02d:%02d', $mon, $mday, $year, $hour, $min, $sec);
}

sub _to_day_month3_year {
    my($sec, $min, $hour, $mday, $mon, $year, $dt) = @_;
    return sprintf('%02d-%.3s-%04d', $mday, $_MONTHS->[$mon], $year);
}

sub _to_day_month3_year_time {
    my($sec, $min, $hour, $mday, $mon, $year, $dt) = @_;
    return sprintf(
	'%02d-%.3s-%04d %02d:%02d:%02d',
	$mday, $_MONTHS->[$mon], $year, $hour, $min, $sec,
    );
}

sub _to_day_month3_year_time_period {
    my($sec, $min, $hour, $mday, $mon, $year, $dt) = @_;
    return sprintf(
	'%02d-%.3s-%04d %02d:%02d:%02d %.2s',
	$mday,
	$_MONTHS->[$mon],
	$year,
	_twelve_hour($hour),
	$min,
	$sec,
	_am_pm($hour),
    );
}

sub _to_full_month {
    my($sec, $min, $hour, $mday, $mon, $year, $dt) = @_;
    return $_MONTHS->[$mon];
}

sub _to_full_month_and_year_uc {
    my($sec, $min, $hour, $mday, $mon, $year, $dt) = @_;
    return uc($_MONTHS->[$mon]) . ", $year";
}

sub _to_full_month_day_and_year {
    my($sec, $min, $hour, $mday, $mon, $year, $dt) = @_;
    return $_MONTHS->[$mon] . " $mday, $year";
}

sub _to_full_month_day_and_year_uc {
    my($sec, $min, $hour, $mday, $mon, $year, $dt) = @_;
    return uc($_MONTHS->[$mon]) . " $mday, $year";
}

sub _to_hour_minute_am_pm_lc {
    my($sec, $min, $hour, $mday, $mon, $year, $dt) = @_;
    ($min, $hour) = $_DT->get_parts($_DT->add_seconds($dt, 30), 'minute', 'hour');
    return sprintf('%d:%02d %s', _twelve_hour($hour), $min, lc(_am_pm($hour)));
}

sub _to_month_and_day {
    my($sec, $min, $hour, $mday, $mon, $year, $dt) = @_;
    return sprintf('%02d/%02d', $mon, $mday);
}

sub _to_month_name_and_day_number {
    my($sec, $min, $hour, $mday, $mon, $year, $dt) = @_;
    return "$_MONTHS->[$mon] $mday";
}

sub _to_rfc822 {
    my($sec, $min, $hour, $mday, $mon, $year, $dt) = @_;
    return $_DT->rfc822($dt);
}

sub _to_time {
    my($sec, $min, $hour, $mday, $mon, $year, $dt) = @_;
    return sprintf('%02d:%02d:%02d', $hour, $min, $sec);
}

sub _twelve_hour {
    my($hour) = @_;
    return $hour == 0 ? 12 : $hour > 12 ? $hour - 12 : $hour;
}

1;
