# Copyright (c) 1999-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::RadioGrid;
use strict;
use Bivio::Base 'HTMLWidget.MultipleChoiceGridBase';
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
    return 'b_radio_grid';
}

sub internal_choice_widget {
    my($self, $value, $label, $attrs) = @_;
    return SPAN_b_radio(Radio({
        %$attrs,
        field => $self->get('field'),
        on_value => $value,
    }));
}

1;
