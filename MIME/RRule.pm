# Copyright (c) 2010 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::MIME::RRule;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_DOW) = {
    map(($_ => lc(substr($_, 0, 2))),
	 qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)),
};
my($_MONTH_PARTS) = {};

    # rrules:
    #  FREQ [YEARLY|MONTHLY|WEEKLY|DAILY|HOURLY|MINUTELY]
    #  UNTIL <date>
    #  BYMONTH <int>
    #  BYDAY <list>(<int>?[SU|MO|TU|WE|TH|FR|SA])
    #  BYMONTHDAY <list>(<int>)
    #  BYYEARDAY <list>(<int>)
    #  BYMINUTE <list>(<int>)
    #  BYHOUR <list>(<int>)
    #  INTERVAL <int>
    #  WKST [SU|MO|TU|WE|TH|FR|SA]
    #  BYSETPOS <int>
    #  COUNT <int>

sub month_parts {
    my($proto, $date) = @_;
    my($month, $year) = $_DT->get_parts($date, qw(month year));
    my($key) = $year . $month;
    return $_MONTH_PARTS->{$key}
	if $_MONTH_PARTS->{$key};
    my($current, $end) = (
	$_DT->date_from_parts(1, $month, $year),
	$_DT->date_from_parts($_DT->get_last_day_in_month($month, $year),
	    $month, $year),
    );
    my($count_by_day) = {};
    my($res) = [];

    while ($_D->compare($current, $end) <= 0) {
	my($index) = $_D->get_parts($current, 'day');
	my($day) = $_DOW->{$_D->english_day_of_week($current)};
	$res->[$index] = [
	    $day,
	    (++($count_by_day->{$day} ||= 0)) . $day,
	    _last_day_index($index, $_D->get_parts($end, 'day')) . $day,
	];
	$current = $_DT->add_days($current, 1);
    }
    return $_MONTH_PARTS->{$key} = $res;
}

sub month_parts_for_day {
    my($proto, $date) = @_;
    return $proto->month_parts($date)->[$_DT->get_parts($date, 'day')];
}

sub process_rrule {
    my($proto, $vevent, $end_date_time) = @_;
    my($rrule) = {
	map(lc($_), map(split('=', $_), split(';', $vevent->{rrule}))),
    };
    return [] unless _is_valid_rrule($rrule, $vevent);
    my($res) = [];
    my($current) = $vevent->{dtstart};
    my($length) = $_DT->diff_seconds($vevent->{dtend}, $current);
    return [] unless _calculate_rrule_until($proto, $rrule);
    my($count) = 0;

    while (1) {
	last
	    if $_DT->compare($current, $end_date_time) > 0;
	last
	    if $rrule->{until}
		&& $_DT->compare($current, $rrule->{until}) > 0;
	push(@$res, {
	    dtstart => $current,
	    dtend => $_DT->add_seconds($current, $length),
	})
	    unless _is_excluded_date($proto, $current, $vevent->{exdate});
	last if $rrule->{count} && ++$count == $rrule->{count};
	$current = _next_date($proto, $rrule, $current, $vevent->{time_zone});
    }
    return $res;
}

sub _calculate_rrule_until {
    my($proto, $rrule) = @_;
    return 1 unless $rrule->{until};
    my($dt, $e) = ($rrule->{until} =~ /^\d{8}$/
        ? $_D
	: $_DT)->from_literal(uc($rrule->{until}));

    if ($e) {
	b_warn('invalid until: ', $rrule, ' err:', $e);
	return 0;
    }
    $rrule->{until} = $dt;
    return 1;
}

sub _is_excluded_date {
    my($proto, $date, $exdates) = @_;
    return 0 unless $exdates;
    return grep($_ eq $date, @$exdates) ? 1 : 0;
}

sub _is_valid_rrule {
    my($rrule, $vevent) = @_;

    unless ($rrule->{freq}) {
	b_warn('rrule missing freq: ', $vevent);
	return 0;
    }

    unless ($rrule->{freq} =~ /^(yearly|monthly|weekly|daily)$/) {
	b_warn('invalid rrule freq: ', $vevent);
	return 0;
    }

    if ($rrule->{wkst} && $rrule->{wkst} ne 'su') {
	b_warn('unsupported rrule wkst: ', $vevent);
	return 0;
    }

    if ($rrule->{interval}) {
	b_warn('rrule interval not yet supported: ', $vevent);
	return 0;
    }

    if ($rrule->{'recurrence-id'}) {
	b_warn('recurrence-id with rrule not supported: ', $vevent);
	return 0;
    }

    if ($_DT->is_date($vevent->{dtstart})) {
	b_warn('skipping date-only rrule: ', $vevent);
	return 0;
    }
    return 1;
}

sub _last_day_index {
    my($day, $last_day_in_month) = @_;
    my($start) = ($day % 7) || 7;
    my($last_week_in_month) = ($start + 4 * 7) > $last_day_in_month
	? 4 : 5;
    return '-' . ($last_week_in_month - ($day - $start) / 7);
}

sub _next_date {
    my($proto, $rrule, $date, $tz) = @_;
    $date = $tz->date_time_from_utc($date);

    if ($rrule->{freq} eq 'weekly' || $rrule->{freq} eq 'monthly') {
	if ($rrule->{byday}) {
	    my(@days) = split(',', $rrule->{byday});

	    foreach my $d (1 .. 365) {
		my($current) = $_DT->add_days($date, $d);
		return $tz->date_time_to_utc($current)
		    if grep({
			my($part) = $_;
			grep($part eq $_, @days);
		    } @{$proto->month_parts_for_day($current)});
	    }
	    b_warn("failed to find byday date: ", $rrule, ' ', $date);
	    return $_DT->get_max;
	}
	b_warn("unhandled weekly: ", $rrule, ' ', $date);
	return $_DT->get_max;
    }
    elsif ($rrule->{freq} eq 'daily') {
	unless ($rrule->{until}) {
	    b_warn("unhandled daily without until: ", $rrule, ' ', $date);
	    return $_DT->get_max;
	}
	return $tz->date_time_to_utc($_DT->add_days($date, 1));
    }
    b_warn("unhandled rrule: ", $rrule, ' ', $date);
    return $_DT->get_max;
}

1;
