# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::DatePicker;
use strict;
use Bivio::Base 'Widget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my(@_DOW) = $_D->english_day_of_week_list;

sub initialize {
    my($self) = @_;
    my($today) = $_D->local_today;
    my($start) = $self->get('start_date');
    my($end) = $self->get('end_date');
    my($field) = $self->resolve_form_model($self)
	->get_field_name_for_html($self->get('field'));
    my($date) = $_D->set_beginning_of_month($start);
    my($months) = [];
    my($has_prev) = 0;
    my($has_next) = 1;
    while ($has_next) {
	my($next_date) = $_D->add_months($date, 1);
	my($delta) = $_D->delta_days($next_date, $end);
	$has_next = 0
	    if $delta <= 0;
	push(
	    @$months,
	    _create_month(
		$field,
		_get_month_days($date),
		$date,
		$today,
		$start,
		$end,
	    )
	);
	$has_prev = 1;
	$date = $next_date;
    }
    $self->put_unless_exists(values => [
	Script('common'),
	Script('b_date_picker'),
	DropDown(
	    Image('date_picker'),
	    DIV(
		Join([@$months]),
		{
		    class => 'b_dp_holder dd_hidden',
		    id => "b_dp_holder_$field",
		},
	    ),
	    {
		no_arrow => 1,
	    },
	),
    ]);
    return;
}

sub _create_month {
    my($form_field, $month_days, $date, $today, $start, $end) = @_;
    my($bom) = $_D->set_beginning_of_month($date);
    my($eom) = $_D->set_end_of_month($date);
    my($has_prev) = $_D->delta_days($start, $bom) > 0;
    my($has_next) = $_D->delta_days($end, $eom) < 0;
    my($day_grid) = [];
    foreach my $week (@$month_days) {
	my($row) = [];
	foreach my $day (@$week) {
	    my($in_range) = $_D->delta_days($day, $start) <= 0
		&& $_D->delta_days($day, $end) >= 0;
	    push(
		@$row,
		DIV(
		    $in_range
			? String($_D->get_parts($day, 'day'))
			: String(' '),
		    {
			class => 'b_dp_cell'
			    . ($in_range
				   ? ' b_dp_active_day'
				   : ' b_dp_inactive_day')
			    . ($_D->is_weekend($day)
				   ? ' b_dp_weekend'
				   : ' b_dp_weekday')
			    . ($_D->delta_days($day, $bom) <= 0
				   && $_D->delta_days($day, $eom) >= 0
				   ? ' b_dp_in_month'
				   : ' b_dp_not_in_month')
			    . ($_D->delta_days($day, $today) == 0
				   ? ' b_dp_today' : ''),
			$in_range
			    ? (ONCLICK => "b_dp_select('$form_field', '@{[$_D->to_mm_dd_yyyy($day)]}')")
			    : (),
		    },
		),
	    );
	}
	push(@$day_grid, $row);
    }
    my($this_month) = $_D->get_parts($date, 'month');
    my($this_year) = $_D->get_parts($date, 'year');
    return DIV(
	Grid([
	    [
		$has_prev
		    ? DIV(String('<'), {
			class => 'b_dp_cell b_dp_arrow',
			ONCLICK => "b_dp_change_month(event, '$form_field', '@{[$_D->get_parts($_D->add_months($date, -1), 'month')]}@{[$_D->get_parts($_D->add_months($date, -1), 'year')]}')",
		    })
		    : DIV(String(' '), {
			class => 'b_dp_cell',
			ONCLICK => 'b_dp_stop_propagation(event)',
		    }),
		DIV(
		    String(
			join(' ', $_D->english_month($this_month), $this_year),
		    ),
		    {
			class => 'b_dp_cell b_dp_month_label',
			cell_colspan => 5,
			ONCLICK => 'b_dp_stop_propagation(event)',
		    },
		),
		$has_next
		    ? DIV(String('>'), {
			class => 'b_dp_cell b_dp_arrow',
			ONCLICK => "b_dp_change_month(event, '$form_field', '@{[$_D->get_parts($_D->add_months($date, 1), 'month')]}@{[$_D->get_parts($_D->add_months($date, 1), 'year')]}')",
		    })
		    : DIV(String(' '), {
			class => 'b_dp_cell',
			ONCLICK => 'b_dp_stop_propagation(event)',
		    }),
	    ],
	    [map({
		DIV(String($_), {
		    class => 'b_dp_cell b_dp_dow',
		    ONCLICK => 'b_dp_stop_propagation(event)',
		}),
	    } qw(S M T W T F S))],
	    @$day_grid,
	]),
	{
	    class => 'b_dp_month '
		. (join('', $_D->get_parts($today, 'month', 'year'))
		eq join('', $this_month, $this_year)
		    ? 'b_dp_visible'
		    : 'b_dp_hidden'),
	    id => "b_dp_${form_field}_${this_month}${this_year}",
	    ONCLICK => 'b_dp_stop_propagation(event)',
	},
    );
    return;
}

sub _get_month_days {
    my($date) = @_;
    my($month) = [];
    my($bom) = $_D->set_beginning_of_month($date);
    my($eom) = $_D->set_end_of_month($date);
    my($d) = $bom;
    while ($_D->delta_days($d, $eom) > 0) {
	push(@$month, _get_week($d));
	$d = $_D->add_days($d, 7);
    }
    while (scalar(@$month) < 6) {
	my($fd) = $month->[0]->[0];
	my($ld) = $month->[-1]->[-1];
	$_D->delta_days($fd, $bom) < $_D->delta_days($eom, $ld)
	    ? unshift(@$month, _get_week($_D->add_days($fd, -7)))
	    : push(@$month, _get_week($_D->add_days($ld, 7)));
    }
    return $month;
}

sub _get_week {
    my($date) = @_;
    my($week) = [];
    $_D->do_iterate(
	sub {
	    push(@$week, shift);
	    return 1
	},
	$_D->set_beginning_of_week($date),
	$_D->set_end_of_week($date),
    );
    return $week;
}

1;
