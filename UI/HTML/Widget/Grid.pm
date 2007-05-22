# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Grid;
use strict;
$Bivio::UI::HTML::Widget::Grid::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::Grid::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::Grid - lays out widgets in a grid (html table)

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Grid;
    Bivio::UI::HTML::Widget::Grid->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::TableBase>

=cut

use Bivio::UI::HTML::Widget::TableBase;
@Bivio::UI::HTML::Widget::Grid::ISA = ('Bivio::UI::HTML::Widget::TableBase');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Grid> lays out widgets in an html table.
There are two types of attributes: table and cell.

=head1 TABLE ATTRIBUTES

=over 4

=item hide_empty_cells : boolean [false]

If true, empty cells will not be rendered.

=item values : array_ref (required)

An array_ref of rows of array_ref of columns (cells).  A cell may
be C<undef>.  A cell may be a widget_value which returns a widget
or a string or it may be a widget or a string.

=back

=head1 CELL ATTRIBUTES

=over 4

=item cell_align : string []

How to align the value within the cell.  The allowed (case
insensitive) values are defined in
L<Bivio::UI::Align|Bivio::UI::Align>.
The value affects the C<ALIGN> and C<VALIGN> attributes of the C<TD> tag.

=item cell_bgcolor : string [] (dynamic)

=item cell_bgcolor : array_ref [] (dynamic)

The value to be passed to the C<BGCOLOR> attribute of the C<TD> tag.
See L<Bivio::UI::Color|Bivio::UI::Color>.

=item cell_class : any [] (dynamic)

=item cell_colspan : int [1]

The value passed to C<COLSPAN> attribute of the C<TD> tag.

=item cell_compact : boolean [false]

If true, the cell will be C<WIDTH=1%>.

=item cell_end : boolean [true]

If false, will not put cell end tag C<E<lt>/TD E<gt>>

=item cell_end_form : boolean [false]

End the form after the cell is closed.  This is a netscape/IE hack
which generates invalid html.

=item cell_expand : boolean [false]

If true, the cell will consume any excess columns in its row.
Excess columns are not the same as C<undef> columns which are
blank place holders.

=item cell_height : int []

Sets the cell height explicitly.

=item cell_height_as_html : array_ref []

Sets the cell height explicitly from a widget value.  The
widget value must return the full attribute, e.g. use
L<Bivio::UI::Icon::get_height_as_html|Bivio::UI::Icon/"get_height_as_html">.

=item cell_nowrap : boolean [false]

If true, the cell will not be wrapped.

=item cell_rowspan : int [1]

The value passed to C<ROWSPAN> attribute of the C<TD> tag.

=item cell_width : int []

Sets the cell width explicitly.

=item cell_width_as_html : array_ref []

Sets the cell width explicitly from a widget value.  The
widget value must return the full attribute, e.g. use
L<Bivio::UI::Icon::get_width_as_html|Bivio::UI::Icon/"get_width_as_html">.

=item row_control : array_ref []

If set, controls the rendering of an entire row.  Can be set
on any cell in the row.

=item row_class : any [] (dynamic)

If set, controls the class of the entire row.  Can be set
on any cell in the row.

=back

=cut

#=IMPORTS
use Bivio::UI::Align;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;
my($_SPACER) = '&nbsp;' x 3;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(array_ref values, hash_ref attributes) : Bivio::UI::HTML::Widget::Grid

Creates a new Grid widget with I<values> and optional I<attributes>.

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Grid

Creates a new Grid widget with I<attributes>.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if exists($fields->{rows});
    $self->initialize_html_attrs;
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
		$c->put_and_initialize(parent => $self);
		my($expand2, $align, $colspan, $rowspan, $width, $height,
		       $width_as_html, $height_as_html)
			= $c->unsafe_get(qw(cell_expand
				cell_align cell_colspan cell_rowspan cell_width
				cell_height cell_width_as_html
                                cell_height_as_html));
		$c->map_invoke(
		    unsafe_initialize_attr =>
			[qw(row_class cell_class cell_bgcolor)]);
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
		_append(\@p, Bivio::UI::Align->as_html($align)) if $align;
		_append(\@p, qq{ rowspan="$rowspan"}) if $rowspan;
		_append(\@p, qq{ colspan="$colspan"}) if $colspan;
		_append(\@p, ' nowrap="1"')
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
	    push(@$r, @p, $c, $end ? "</td>\n" : '',
		   $form_end ? '</form>' : '');
	}
    }
    $fields->{rows} = $rows;
    return;
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
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


=for html <a name="layout_buttons"></a>

=head2 layout_buttons(array_ref buttons, int max_width)

Sets I<values> to I<buttons> laid out appropriately for I<max_width>,
i.e. the maximum width of the buttons in characters.  See
I<RadioGrid> and I<CheckboxGrid> for examples.

=cut

sub layout_buttons {
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

=for html <a name="layout_buttons_row_major"></a>

=head2 layout_buttons(array_ref buttons, int column_count)

Lays out I<column_count> in row major (across the rows) format.

Here's a three column example:

    [
        button1, button2, button3,
        button4, button5, button6,
        ...
    ]

=cut

sub layout_buttons_row_major {
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

=for html <a name="render"></a>

=head2 render(string_ref buffer)

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    $$buffer .= $self->render_start_tag($source, '');
    my($r, $c);
 ROW: foreach $r (@{$fields->{rows}}) {
	my($row) = "<tr>\n";
	foreach $c (@$r) {
	    # Look up widget value
	    my($is_widget_value) = ref($c) eq 'ARRAY';
	    my($w) = $is_widget_value ? $source->get_widget_value(@$c) : $c;
	    if (ref($w)) {
		# Render widget
		my($rc) = $w->unsafe_get('row_control');
		next ROW if $rc && !$source->get_widget_value(@$rc);
		unless ($is_widget_value) {
		    my($b);
		    # Only first row_class counts
		    $row =~ s/^<tr>/<tr class="$b">/
			if $c->unsafe_render_attr(
			    'row_class', $source, \$b) && $b;
		    $row .= Bivio::UI::Color->format_html($b, 'bgcolor', $req)
			if $b = $c->render_simple_attr('cell_bgcolor', $source);
		    $row .= qq{ class="$b"}
			if $b = $c->render_simple_attr('cell_class', $source);
		    # Close cell start always.  See initialization.
		    $row .= '>';
		}
		$w->render($source, \$row);
	    }
	    elsif (defined($w)) {
		$row .= $w;
	    }
	    # else undefined, render nothing
	}
	$row .= '</tr>';

	# don't redner empty cells for 'hide_empty_cells'
	$row =~ s!<td[^>]*></td>!!gs
	    if $self->unsafe_get('hide_empty_cells');

	# If row is completely empty, don't render it.
	$$buffer .= $row unless $row =~ m!^<tr>\n*<td[^>]*></td>\n*</tr>$!s;
    }
    $$buffer .= $self->render_end_tag($source, '');
    return;
}

#=PRIVATE METHODS

# _append(array_ref list, string element)
# _append(array_ref list, ref element)
#
# Appends element literally to $list->[$#list] both parts are a string,
# else pushes on a new element.
#
sub _append {
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

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
