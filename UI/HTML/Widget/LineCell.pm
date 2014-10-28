# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::LineCell;
use strict;
use Bivio::Base 'UI.Widget';
use Bivio::UI::ViewLanguageAUTOLOAD;

# C<Bivio::UI::HTML::Widget::LineCell> draws a double line within
# a table cell (C<TD> tag not rendered).
#
# The color of the space between the lines is C<page_bg>.
#
# color : string [table_separator]
#
# Color of the line(s).
#
# count : int [1]
#
# Number of lines.
#
# height : int [1]
#
# The height of a single line of the two lines and the space in between
# in pixels.


sub initialize {
    # (self) : undef
    # Initializes static information.
    my($self) = @_;
    return if $self->unsafe_get('value');
    my($count) = $self->get_or_default('count', 1);
    my($line) = "<td class=\"line_cell\">"
	. vs_clear_dot_as_html(1, $self->get_or_default('height', 1))
	. "</td>";
    $self->put(value => qq{<table width="100%" cellspacing="0"}
	. qq{ cellpadding="0" border="0">\n}
	. ((qq{<tr!COLOR!>$line</tr>\n<tr!PAGE_BG!>$line</tr>\n}) x --$count)
	. qq{<tr!COLOR!>$line</tr></table>});
    return;
}

sub render {
    my($self, $source, $buffer) = @_;
    my($value) = $self->get('value');
    my($c) = $self->get_or_default('color', 'table_separator');
    $c = $c
	? b_use('FacadeComponent.Color')->format_html($c, 'bgcolor', $source->req)
	: '';
    $value =~ s/!COLOR!/$c/g;
    $c = b_use('FacadeComponent.Color')->format_html('page_bg', 'bgcolor', $source->req)
	|| '';
    $value =~ s/!PAGE_BG!/$c/g;
    $$buffer .= $value;
    return;
}

1;
