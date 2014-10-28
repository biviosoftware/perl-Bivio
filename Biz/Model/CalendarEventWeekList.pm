# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventWeekList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_DT) = b_use('Type.DateTime');
my($_D) = b_use('Type.Date');

sub day_of_week_suffix_list {
    return map(lc($_), $_DT->english_day_of_week_list);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        $self->field_decl(
	    primary_key => [
	        [qw(start_of_week DateTime)],
	    ],
	    other => [
		map((
		    ["create_date_$_", 'Date'],
		    ["in_this_month_$_", 'Boolean'],
		    ["day_of_month_$_", 'Integer'],
		    ["is_today_$_", 'Boolean'],
		    ["event_list_$_", 'Model.CalendarEventDayList'],
		), $self->day_of_week_suffix_list),
	    ],
	    other_query_keys => ['b_month_list'],
	),
    });
}

sub internal_load_rows {
    my($self, $query) = @_;
    my($month_list) = $query->get('b_month_list');
    my($this_month) = $month_list->this_month;
    my($months) = _months($month_list);
    my($rows) = [];
    my($today) = $_D->from_datetime(
	$month_list->auth_user_time_zone->date_time_from_utc($_DT->now));
    my($prev_dow) = '';
    $_DT->do_iterate(
	sub {
	    my($dt) = @_;
	    $dt = $month_list->auth_user_time_zone->date_time_from_utc($dt)
		if $month_list->is_time_zone;
	    my($dow) = lc($_DT->english_day_of_week($dt));
	    push(@$rows, {})
		if $dow eq 'sunday' && $dow ne $prev_dow;
	    $prev_dow = $dow;
	    my($month, $day) = $_DT->get_parts($dt, 'month', 'day');
	    my($date) = $_D->from_datetime($dt);
	    $rows->[$#$rows] = {
		%{$rows->[$#$rows]},
		"create_date_$dow" => $date,
		"in_this_month_$dow" => $month eq $this_month ? 1 : 0,
		"is_today_$dow" => $_D->is_equal($date, $today),
		"day_of_month_$dow" => $day,
		"day_list_$dow" => $self->new_other('CalendarEventDayList')
		    ->load_all({b_rows => [sort({
			$_DT->compare($a->{dtstart_tz}, $b->{dtstart_tz})
			    || $_DT->compare($a->{dtend_tz}, $b->{dtend_tz})
		    } @{($months->[$month] || [])->[$day] || []})]}),
	    };
	    return 1;
	},
	$month_list->begin_and_end_date_times,
    );
    return $rows;
}

sub _months {
    my($month_list) = @_;
    my($res) = [];
    $month_list->do_rows(sub {
	my($row) = shift->get_shallow_copy;
	$_DT->do_iterate(
	    sub {
		my($dt) = @_;
		my($month, $day) = $_DT->get_parts($dt, 'month', 'day');
		push(@{($res->[$month] ||= [])->[$day] ||= []}, $row);
		return 1;
	    },
	    $row->{dtstart_tz},
	    $row->{dtend_tz},
	);
	return 1;
    });
    return $res;
}

1;
