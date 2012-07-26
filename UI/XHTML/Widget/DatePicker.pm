# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::DatePicker;
use strict;
use Bivio::Base 'Widget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_HTMLDT) = b_use('HTMLWidget.DateTime');

sub initialize {
    my($self, $source) = @_;
    my($start) = $self->unsafe_get('start_date');
    my($end) = $self->unsafe_get('end_date');
    my($field) = $self->resolve_form_model($self)
	->get_field_name_for_html($self->get('field'));
    $self->put_unless_exists(values => [
	Script('common'),
	Script('b_date_picker'),
	DropDown(
	    Image('date_picker'),
	    DIV(
		_create_month($field),
		{
		    class => 'b_dp_holder dd_hidden',
		    id => "b_dp_holder_$field",
		},
	    ),
	    {
		no_arrow => 1,
		link_onclick => "b_dp_set_month('$field', null, "
		    . join(', ',
			   $start
			       ? "b_dp_get_date('@{[$_DT->to_mm_dd_yyyy($start)]}')"
			       : "null",
			   $end
			       ? "b_dp_get_date('@{[$_DT->to_mm_dd_yyyy($end)]}')"
			       : "null")
		    . ')',
	    },
	),
    ]);
    return;
}

sub _create_month {
    my($form_field) = @_;
    my($day_grid) = [];
    foreach my $week (0 .. 5) {
	my($row) = [];
	foreach my $day (0 .. 6) {
	    push(
		@$row,
		DIV(
		    String(' '),
		    {
			class => 'b_dp_cell'
			    . ($day == 0 || $day == 6
				   ? ' b_dp_weekend'
				   : ' b_dp_weekday'),
			id => "b_dp_holder_${form_field}_${week}${day}",
		    },
		),
	    );
	}
	push(@$day_grid, $row);
    }
    return DIV(
	Grid([
	    [
		DIV(String('<'), {
		    class => 'b_dp_cell b_dp_arrow',
		    id => "b_dp_${form_field}_left_arrow",
		}),
		DIV(
		    String('month'),
		    {
			class => 'b_dp_cell b_dp_month_label',
			id => "b_dp_${form_field}_month",
			cell_colspan => 5,
		    },
		),
		DIV(String('>'), {
		    class => 'b_dp_cell b_dp_arrow',
		    id => "b_dp_${form_field}_right_arrow",
		}),
	    ],
	    [map({
		DIV(String($_), {
		    class => 'b_dp_cell b_dp_dow',
		}),
	    } qw(S M T W T F S))],
	    @$day_grid,
	]),
	{
	    class => 'b_dp_month',
	    ONCLICK => 'b_dp_stop_propagation(event)',
	},
    );
}

1;
