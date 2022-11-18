# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Grid;
use strict;
use Bivio::Base 'HTMLWidget.TableBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

# C<Bivio::UI::HTML::Widget::Grid> lays out widgets in an html table.
# There are two types of attributes: table and cell.
#
#
#
# hide_empty_cells : boolean [false]
#
# If true, empty cells will not be rendered.
#
# values : array_ref (required)
#
# An array_ref of rows of array_ref of columns (cells).  A cell may
# be C<undef>.  A cell may be a widget_value which returns a widget
# or a string or it may be a widget or a string.
#
#
#
#
# cell_align : string []
#
# How to align the value within the cell.  The allowed (case
# insensitive) values are defined in
# L<Bivio::UI::Align|Bivio::UI::Align>.
# The value affects the C<ALIGN> and C<VALIGN> attributes of the C<TD> tag.
#
# cell_bgcolor : string [] (dynamic)
#
# cell_bgcolor : array_ref [] (dynamic)
#
# The value to be passed to the C<BGCOLOR> attribute of the C<TD> tag.
# See L<b_use('FacadeComponent.Color')|Bivio::UI::Color>.
#
# cell_class : any [] (dynamic)
#
# cell_colspan : int [1]
#
# The value passed to C<COLSPAN> attribute of the C<TD> tag.
#
# cell_compact : boolean [false]
#
# If true, the cell will be C<WIDTH=1%>.
#
# cell_end : boolean [true]
#
# If false, will not put cell end tag C<E<lt>/TD E<gt>>
#
# cell_end_form : boolean [false]
#
# End the form after the cell is closed.  This is a netscape/IE hack
# which generates invalid html.
#
# cell_expand : boolean [false]
#
# If true, the cell will consume any excess columns in its row.
# Excess columns are not the same as C<undef> columns which are
# blank place holders.
#
# cell_height : int []
#
# Sets the cell height explicitly.
#
# cell_height_as_html : array_ref []
#
# Sets the cell height explicitly from a widget value.  The
# widget value must return the full attribute, e.g. use
# L<Bivio::UI::Icon::get_height_as_html|b_use('FacadeComponent.Icon')/"get_height_as_html">.
#
# cell_nowrap : boolean [false]
#
# If true, the cell will not be wrapped.
#
# cell_rowspan : int [1]
#
# The value passed to C<ROWSPAN> attribute of the C<TD> tag.
#
# cell_width : int []
#
# Sets the cell width explicitly.
#
# cell_width_as_html : array_ref []
#
# Sets the cell width explicitly from a widget value.  The
# widget value must return the full attribute, e.g. use
# L<Bivio::UI::Icon::get_width_as_html|b_use('FacadeComponent.Icon')/"get_width_as_html">.
#
# row_control : array_ref []
#
# If set, controls the rendering of an entire row.  Can be set
# on any cell in the row.
#
# row_class : any [] (dynamic)
#
# If set, controls the class of the entire row.  Can be set
# on any cell in the row.

my($_IDI) = __PACKAGE__->instance_data_index;
my($_SPACER) = '&nbsp;' x 3;
my($_END_COL) = "</td>\n";

sub initialize {
    # (self) : undef
    # Initializes static information.
    my($self, $source) = @_;
    my($fields) = $self->[$_IDI];
    return if exists($fields->{rows});
    $self->initialize_html_attrs($source);
    my($num_cols) = 0;
    my($rows, $r) = $self->get('values');
    foreach $r (@$rows) {
        $num_cols = int(@$r) if $num_cols < int(@$r);
    }
    foreach $r (@$rows) {
        # search for "expand"
        my($expand_cols) = $num_cols - int(@$r) + 1;
        my(@cols) = @$r;
        $#$r = -1;
        my($c);
        foreach $c (@cols) {
            my(@p) = ('<td');
            my($end) = 1;
            my($form_end) = 0;
            if (ref($c) eq 'ARRAY') {
                # Widget value, nothing to prepare.
                _append(\@p, '>');
            }
            elsif (ref($c)) {
                # May set attributes on itself
                $c->initialize_with_parent($self, $source);
                my($expand2, $align, $colspan, $rowspan, $width, $height,
                       $width_as_html, $height_as_html)
                        = $c->unsafe_get(qw(cell_expand
                                cell_align cell_colspan cell_rowspan cell_width
                                cell_height cell_width_as_html
                                cell_height_as_html));
                $c->map_invoke(
                    unsafe_initialize_attr =>
                        [qw(row_class cell_class cell_bgcolor)],
                        undef,
                        [$source],
                );
                if ($expand2) {
                    # First expanded cell gets all the rest of the columns.
                    # If the grid is expanded itself, then set this cell's
                    # width to 100%.
                    _append(\@p, qq{ colspan="$expand_cols"})
                        if $expand_cols > 1;
                    _append(\@p, ' width="100%"') if $expand2 && !$width;
                    $expand_cols = 1;
                }
#TODO: Need better crosschecking
                _append(\@p, ' width="1%"')
                        if $c->get_or_default('cell_compact', 0);
                _append(\@p, b_use('UI.Align')->as_html($align)) if $align;
                _append(\@p, qq{ rowspan="$rowspan"}) if $rowspan;
                _append(\@p, qq{ colspan="$colspan"}) if $colspan;
                _append(\@p, ' nowrap="nowrap"')
                    if $c->get_or_default('cell_nowrap', 0);
#TODO: Should be a number or percent?
                _append(\@p, qq! width="$width"!) if $width;
                _append(\@p, qq! height="$height"!) if $height;
                _append(\@p, $width_as_html) if $width_as_html;
                _append(\@p, $height_as_html) if $height_as_html;
                $end = $c->get_or_default('cell_end', 1);
                $form_end = $c->get_or_default('cell_end_form', 0);
            }
            elsif (!defined($c)) {
                # Replace undef cells with something real.
                _append(\@p, '>');
                $c = '';
            }
            elsif ($c =~ /^\s+$/) {
                $c =~ s/\s/&nbsp;/g;
                _append(\@p, ' width="1%">');
            }
            else {
                _append(\@p, '>');
            }
            # Render scalars literally.
            push(@$r, @p, $c, $end ? $_END_COL : '',
                   $form_end ? '</form>' : '');
        }
    }
    $fields->{rows} = $rows;
    return;
}

sub internal_new_args {
    # (proto, any, ...) : any
    # Implements positional argument parsing for L<new|"new">.
    my($proto, $values, $attributes) = @_;
    return "'values' must be an array_ref (rows) of array_refs (cells)"
        unless ref($values) eq 'ARRAY';
    return "'attributes' must be a hash_ref (missing extra square brackets?)"
        if $attributes && ref($attributes) ne 'HASH';
    return {
        values => $values,
        ($attributes ? %$attributes : ()),
    };
}

sub layout_buttons {
    # (self, array_ref, int) : undef
    # Sets I<values> to I<buttons> laid out appropriately for I<max_width>,
    # i.e. the maximum width of the buttons in characters.  See
    # I<RadioGrid> and I<CheckboxGrid> for examples.
    my($self, $buttons, $max_width) = @_;
    my(@rows) = ();
    my($s) = '&nbsp;' x 3;

    # Max 4 items across in one row
    if (int(@$buttons) * $max_width < 60 && int(@$buttons) <= 4) {
        @$buttons = map {($_, $s)} @$buttons;
        pop(@$buttons);
        push(@rows, $buttons);
    }
    elsif ($max_width < 20) {
        my($third) = int((int(@$buttons) + 2)/3);
        for (my($i) = 0; $i < $third; $i++) {
            push(@rows, [$buttons->[$i],
                $s, $buttons->[$i+$third] || $s,
                $s, $buttons->[$i+2*$third] || $s]);
        }
    }
    elsif ($max_width < 30) {
        my($half) = int((int(@$buttons) + 1)/2);
        for (my($i) = 0; $i < $half; $i++) {
            push(@rows, [$buttons->[$i], $s, $buttons->[$i+$half] || $s]);
        }
    }
    else {
        push(@rows, [shift(@$buttons)]) while @$buttons;
    }

    $self->put(values => \@rows);
    return;
}

sub layout_buttons_row_major {
    # (self, array_ref, int) : undef
    # Lays out I<column_count> in row major (across the rows) format.
    #
    # Here's a three column example:
    #
    #     [
    #         button1, button2, button3,
    #         button4, button5, button6,
    #         ...
    #     ]
    my($self, $buttons, $column_count) = @_;
    my(@buttons) = @$buttons;
    $column_count--;
    my(@rows);
    while (@buttons) {
        my($row) = [map {
            (shift(@buttons) || $_SPACER, $_SPACER);
        } 0..$column_count];

        # Get rid of last separator and push on another row
        pop(@$row);
        push(@rows, $row);
    }
    $self->put(values => \@rows);
    return;
}

sub new {
    # (proto, array_ref, hash_ref) : Widget.Grid
    # (proto, hash_ref) : Widget.Grid
    # Creates a new Grid widget with I<values> and optional I<attributes>.
    #
    #
    # Creates a new Grid widget with I<attributes>.
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

sub control_on_render {
    # (self, string_ref) : undef
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($b) = $self->render_start_tag($source, '');
    my($r, $c);
    my($hide_cells) = $self->render_simple_attr('hide_empty_cells', $source);
 ROW: foreach $r (@{$fields->{rows}}) {
        my($row) = "<tr>\n";
        foreach $c (@$r) {
            # Look up widget value
            my($is_widget_value) = ref($c) eq 'ARRAY';
            my($w) = $is_widget_value ? $source->get_widget_value(@$c) : $c;
            my($cell) = '';
            if (ref($w)) {
                next ROW
                    if $w->has_keys('row_control')
                        && !$w->render_simple_attr('row_control', $source);
                unless ($is_widget_value) {
                    my($b);
                    # Only first row_class counts
                    $row =~ s/^<tr>/<tr$b>/
                        if $b = vs_html_attrs_render_one($w, $source, 'row_class');
                    $cell .= b_use('FacadeComponent.Color')->format_html($b, 'bgcolor', $req)
                        if $b = $c->render_simple_attr('cell_bgcolor', $source);
                    $cell .= vs_html_attrs_render_one($c, $source, 'cell_class')
                        . '>';
                }
                $w->render($source, \$cell);
            }
            elsif (defined($w)) {
                $cell = $w;
            }
            $row .= $cell;
            $row =~ s{<td[^>]*></td>\s*$}{}
                if $hide_cells && $cell eq $_END_COL;
        }
        $row .= '</tr>';
        $b .= $row
            unless $row =~ m{^<tr[^>]*>\n*(?:<td[^>]*></td>\n*)*</tr>$}s;
    }
    $$buffer .= $b . $self->render_end_tag($source, '')
        unless $b =~ m{^<table[^>]*>$}s;
    return;
}

sub _append {
    # (array_ref, string) : undef
    # (array_ref, ref) : undef
    # Appends element literally to $list->[$#list] both parts are a string,
    # else pushes on a new element.
    my($list, $element) = @_;
    if (ref($list->[$#$list]).ref($element) eq '') {
        # both are strings
        $list->[$#$list] .= $element;
    }
    else {
        # Last or this element is a ref
        push(@$list, $element);
    }
    return;
}

1;
