# Copyright (c) 1999-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::MultipleChoiceGridBase;
use strict;
use Bivio::Base 'HTMLWidget.MultipleChoice';
use Bivio::UI::ViewLanguageAUTOLOAD;


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

sub GRID_CLASS {
    b_die('abstract method');
}

sub initialize {
    my($self) = @_;
    return
	if $self->unsafe_get('value');
    shift->SUPER::initialize(@_);
    b_die('static items only for RadioGrid')
	unless $self->unsafe_get('items');
    my($max_width) = 0;
    my($items) = $self->map_by_two(sub {
	my($k, $v) = @_;
	return $self->internal_choice_widget(
	    $k, $v, _choice_widget_attrs($self, $k, $v, \$max_width),
	);
    }, $self->get('items'));

    my($grid) = Grid();
    if ($self->unsafe_get('column_count')) {
	$grid->layout_buttons_row_major($items, $self->get('column_count'));
    }
    else {
	$grid->layout_buttons($items, $max_width);
    }
    $grid->put(class => $self->GRID_CLASS);
    $self->initialize_attr(value => $grid);
    return;
}

sub internal_choice_widget {
    b_die('abstract method');
}

sub render {
    my($self, $source, $buffer) = @_;
    $self->get('value')->render($source, $buffer);
    return shift->SUPER::render(@_);
}

sub _choice_widget_attrs {
    my($self, $value, $label, $max_width) = @_;
    return {
	label => b_use('UI.Widget')->is_blesser_of($label)
	    ? _max_width($max_width, $label)
	    : SPAN_b_item(_max_width($max_width, $label)),
	auto_submit => $self->get_or_default('auto_submit', 0),
	$self->unsafe_get('event_handler')
	    ? (event_handler => $self->get('event_handler'))
	    : (),
    };
}

sub _max_width {
    # Updates $$max and returns label.
    my($max, $label) = @_;
    $$max = length($label)
	if $$max < length($label);
    return $label;
}

1;
