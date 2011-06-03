# Copyright (c) 1999-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::RadioGrid;
use strict;
use Bivio::Base 'HTMLWidget.MultipleChoice';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

# C<Bivio::UI::HTML::Widget::RadioGrid> create a grid of radio
# buttons.  The grid is shaped according to the length and width
# of the buttons.
#
# auto_submit : boolean [0]
#
# Should the a click submit the form?
#
# column_count : int [undef]
#
# If defined, forces the number of columns to a fixed width.

sub initialize {
    my($self) = @_;
    return
	if $self->unsafe_get('value');
    shift->SUPER::initialize(@_);
    b_die('static items only for RadioGrid')
	unless $self->unsafe_get('items');
    my($max_width) = 0;
    # Convert to Radio
    my($items) = $self->map_by_two(sub {
	my($k, $v) = @_;
	return SPAN_b_radio(Radio({
	    field => $self->get('field'),
	    value => $k,
	    label => b_use('UI.Widget')->is_blessed($v)
		? _max_width(\$max_width, $v)
	        : SPAN_b_item(_max_width(\$max_width, $v)),
	    auto_submit => $self->get_or_default('auto_submit', 0),
	    $self->unsafe_get('event_handler')
		? (event_handler => $self->get('event_handler'))
		: (),
	}));
    }, $self->get('items'));

    my($grid) = Grid();
    # Layout the buttons
    if ($self->unsafe_get('column_count')) {
	$grid->layout_buttons_row_major($items, $self->get('column_count'));
    }
    else {
	$grid->layout_buttons($items, $max_width);
    }
    $grid->put(class => 'b_radio_grid');
    $self->initialize_attr(value => $grid);
    return;
}

sub render {
    my($self, $source, $buffer) = @_;
    $self->get('value')->render($source, $buffer);
    return shift->SUPER::render(@_);
}

sub _max_width {
    # Updates $$max and returns label.
    my($max, $label) = @_;
    $$max = length($label)
	if $$max < length($label);
    return $label;
}

1;
