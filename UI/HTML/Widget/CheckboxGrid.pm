# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::CheckboxGrid;
use strict;
use Bivio::Base 'HTMLWidget.MultipleChoiceGridBase';
b_use('UI.ViewLanguageAUTOLOAD');


sub GRID_CLASS {
    return 'b_checkbox_grid';
}

sub internal_choice_widget {
    my($self, $value, $label, $attrs) = @_;
    return SPAN_b_checkbox(Checkbox({
	%$attrs,
	field => b_use('Biz.FormModel')->format_enum_set_field(
	    $self->get('field'),
	    $value,
	),
    }));
}

1;
