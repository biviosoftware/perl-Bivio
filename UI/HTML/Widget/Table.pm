# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Table;
use strict;
$Bivio::UI::HTML::Widget::Table::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Table - renders a ListModel in an html table

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Table;
    Bivio::UI::HTML::Widget::Table->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Table::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Table> renders a
L<Bivio::Biz::ListModel|Bivio::Biz::ListModel> in a table.

=head1 FACADE ATTRIBUTES

=over 4

=item Bivio::UI::HTML.table_default_align : string

Default table alignment name.

=item Bivio::UI::HTML.page_left_margin : int

If greater than zero, expand to "95%".  Otherwise, "100%"?

=back

=head1 TABLE ATTRIBUTES

=over 4

=item align : string [Bivio::UI::HTML.table_align]

How to align the table.  The allowed (case
insensitive) values are defined in
L<Bivio::UI::Align|Bivio::UI::Align>.
The value affects the C<ALIGN> attributes of the C<TABLE> tag.

=item border : int [0]

Width of border surrounding the table and its cells.

=item cellpadding : int [5]

Padding inside each cell in pixels.

=item cellspacing : int [0]

Spacing around each cell in pixels.

=item columns : array_ref (required)

The column names to display, in order. Column headings will be assigned
by looking up name.'_HEADING' in the Bivio::UI::Label enum.
Each value in columns may be one of:

=over 4

=item string

The field name in the ListModel.

=item array_ref

First element is the field.  Second is a hash_ref containing
attributes.

=item hash_ref

May or may not have a field and the attrs describe how to create the
widget.  The name of field is in the attribute named C<field>.

=back

An empty field will be rendered as a empty cell.

=item column_enabler : UNIVERSAL

The object which determines which columns to dynamically enable.
If present, then the method:

  enable_column(string name, Bivio::UI::HTML::Widget::Table table) : boolean

will be invoked upon it prior to rendering the table to determine which
columns to display.

=item empty_list_widget : Bivio::UI::HTML::Widget []

If set, the widget to display instead of the table when the
list_model is empty.

The I<source> will be the original source, not the list_model.

If not set, displays an empty table (with headers).

=item end_tag : boolean [true]

If false, this widget won't render the C<&gt;/TABLE&lt;> tag.

=item even_row_bgcolor : string [table_even_row_bg]

The stripe color to use for even rows as defined by
L<Bivio::UI::Color|Bivio::UI::Color>.  If the color is
undefined, no striping will occur.

=item expand : boolean [false]

If true, the table C<WIDTH> will be C<95%> or C<100%> depending
on Bivio::UI::HTML.page_left_margin.

=item list_class : string (required)

The class name of the list model to be rendered. The list_class is used
to determine the column cell types for the table. The
C<Bivio::Biz::Model::> prefix will be inserted if need be.

=item odd_row_bgcolor : string [table_odd_row_bg]

The stripe color to use for odd rows as defined by
L<Bivio::UI::Color|Bivio::UI::Color>.  If the color is
undefined, no striping will occur.

=item show_headings : boolean [true]

If true, then the column headings are rendered.

=item source_name : string [list_class] (get_request)

The name of the list model as it appears upon the request. This value will
default to the 'list_class' attribute if not defined.

=item start_tag : boolean [true]

If false, this widget won't render the C<&gt;TABLE&lt;>tag.

=item summarize : boolean [false]

If true, the list's summary model will be rendered.  Will be true
implicitly, if I<summary_line_type> is set.

=item summary_line_type : string

The type of summary line to render.
If defined, valid types are '-' for a single line, '=' for a double line.
If true, sets I<summarize> to true if I<summarize> is not already set.

=item title : string

The name of the table.

=item trailing_separator : boolean [false]

A separator will separate the cells from the summary.  The color will be
C<table_separator>.

=back

=head1 CELL ATTRIBUTES

=over 4

=item column_align : string [LEFT]

How to align the value within the cell or heading.  The allowed (case
insensitive) values are defined in
L<Bivio::UI::Align|Bivio::UI::Align>.
The value affects the C<ALIGN> and C<VALIGN> attributes of the C<TD> tag.

=item column_control : value

A widget value which, if set, must be a true value to render the column.

=item column_expand : boolean [false]

If true, the column will be C<width="100%">.

=item column_heading : string

The heading label to use for the columns heading. By default, the column
name is used to look up the heading label.  The name of the label
is the I<column_heading> with C<_HEADING> appended.

=item column_heading : string_ref

B<DEPRECATED>.

The literal text of the label.  The indirected value will be
looked up once and used.  This avoids a second lookup.  Only
used by DescriptivePageForm.

=item field : string

Name of the column.  By default, it is the positional name.

=item column_nowrap : boolean [false]

If true, the column won't wrap text.

=item column_order_by : array_ref

The list of sort fields to use when sorting on this column.
By default, this is the field name of the column.

=item column_span : int [1]

The value for the C<COLSPAN> tag, which is not inserted if C<1>.

=item column_summarize : boolean

Determines whether the specified cell will be summarized. Only applies to
numeric columns. By default, numeric columns always summarize.

=item column_widget : Bivio::UI::HTML::Widget

The widget which will be used to render the column. By default the column
widget is based on the column's field type.

=item heading_align : string [S]

How to align the heading.
The value affects the C<ALIGN> and C<VALIGN> attributes of the C<TH> tag.

=back

=cut

#=IMPORTS

use Bivio::Biz::Model;
use Bivio::UI::Align;
use Bivio::UI::Color;
use Bivio::UI::HTML::WidgetFactory;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::LineCell;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::Label;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Table

Creates a new Table widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
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
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{headings};

    # Make sure the class is loaded
    my($list) = Bivio::Biz::Model->get_instance($self->get('list_class'));
    $self->put(source_name => ref($list))
	    unless $self->has_keys('source_name');

    # Puts table_cell as the default font.
    $self->put(string_font => 'table_cell')
	    unless defined($self->ancestral_get('string_font', undef));

    my($columns) = $self->get('columns');
    my($lm) = $list;
    if ($list->isa('Bivio::Biz::ListFormModel')) {
        $lm = $list->get_info('list_class')->get_instance;
    }
    my($sort_columns) = $lm->get_info('order_by_names');

    # Create widgets for each heading, column, and summary
    my($cells) = [];
    my($headings) = [];
#TODO: optimize, don't create summary widgets unless they are needed
    my($summary_cells) = [];
    my($summary_lines) = [];
    foreach my $col (@$columns) {
	my($attrs);
	if (ref($col) eq 'ARRAY') {
	    ($col, $attrs) = @$col;
	    $attrs->{field} = $col unless $attrs->{field};
	    $col = $attrs->{field} unless $col;
	}
	elsif (ref($col) eq 'HASH') {
	    $attrs = $col;
	    $col = $attrs->{field} || '';
	}
	else {
	    $attrs = {field => $col};
	}
	my($cell) = _get_cell($self, $list, $col, $attrs);
	push(@$cells, $cell);

        # Can we sort on this column?
        my($sort_fields) = $cell->unsafe_get('column_order_by')
                || [grep($col eq $_, @$sort_columns)]
                        if defined($sort_columns);

        push(@$headings, _get_heading($self, $lm, $col, $cell, $sort_fields));
	push(@$summary_cells, _get_summary_cell($self, $cell));
	push(@$summary_lines, _get_summary_line($self, $cell));
    }
    $fields->{headings} = $headings;
    $fields->{cells} = $cells;
    $fields->{summary_lines} = $summary_lines;
    $fields->{summary_cells} = $summary_cells;

    my($title) = $self->unsafe_get('title');
    if (defined($title)) {
	$fields->{title} = Bivio::UI::HTML::Widget::String->new({
            value => "\n$title\n",
            string_font => 'table_heading',
        });
	$fields->{title}->initialize;
    }

    # heading separator and summary
    $fields->{separator} = Bivio::UI::HTML::Widget::LineCell->new({
	height => 1,
	color => 'table_separator',
    });
    $fields->{separator}->initialize;

    $fields->{empty_list_widget} = $self->unsafe_get('empty_list_widget');
    if ($fields->{empty_list_widget}) {
	$fields->{empty_list_widget}->put(parent => $self);
	$fields->{empty_list_widget}->initialize;
    }

    my($prefix) = "\n<table border=";
    $prefix .= $self->get_or_default('border', 0);
    $prefix .= ' cellspacing='.$self->get_or_default('cellspacing', 0);
    $prefix .= ' cellpadding='.$self->get_or_default('cellpadding', 5);
    $fields->{table_prefix} = $prefix;
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the table upon the output buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $source->get_request;
    my($list) = $req->get($self->get('source_name'));

    # check for an empty list
    return $fields->{empty_list_widget}->render($source, $buffer)
	    if $fields->{empty_list_widget}
		    && $list->get_result_set_size == 0;

    my($headings, $cells, $summary_cells, $summary_lines) =
	    _get_enabled_widgets($self, $source);

    if ($self->get_or_default('start_tag', 1)) {
	$$buffer .= $fields->{table_prefix};
	my($html) = $req->get('Bivio::UI::HTML');
	$$buffer .= Bivio::UI::Align->as_html(
		$self->get_or_default('align',
                        $html->get_value('table_default_align')));

	$$buffer .= $html->get_value('page_left_margin')
		? ' width="95%"' : ' width="100%"'
			if $self->unsafe_get('expand');
	$$buffer .= '>';
    }

#TODO: optimize, for static tables just compute this once in initialize
    my($colspan) = _get_column_count($cells);

    # table title
    if ($fields->{title}) {
	$$buffer .= "\n<tr><td colspan=$colspan>";
	$fields->{title}->render($list, $buffer);
	$$buffer .= "</td>\n</tr>",
    }

    # headings
    if ($self->get_or_default('show_headings', 1)) {
	_render_row($headings, $list, $buffer);
	$$buffer .= "\n<tr><td colspan=$colspan>";
	$fields->{separator}->render($list, $buffer);
	$$buffer .= "</td>\n</tr>",
    }

    # rows
    $list->reset_cursor;
    my($is_even_row) = 0;
    # alternating row colors
    my($odd_row) = "\n<tr"
	    .Bivio::UI::Color->format_html(
		    $self->get_or_default('odd_row_bgcolor',
			    'table_odd_row_bg'),
		    'bgcolor', $req).'>';
    my($even_row) = "\n<tr"
	    .Bivio::UI::Color->format_html(
		    $self->get_or_default('even_row_bgcolor',
			    'table_even_row_bg'),
		    'bgcolor', $req).'>';


    while ($list->next_row) {
	_render_row($cells, $list, $buffer,
		$is_even_row ? $even_row : $odd_row, 1);
	$is_even_row = !$is_even_row;
    }

    # separator
    if ($self->unsafe_get('trailing_separator')) {
	$$buffer .= "\n<tr><td colspan=$colspan>";
	$fields->{separator}->render($list, $buffer);
	$$buffer .= "</td>\n</tr>",
    }

    # summary
    if ($self->get_or_default('summarize',
	    $self->unsafe_get('summary_line_type') ? 1 : 0)) {
	my($summary_list) = $list->get_summary;
	_render_row($summary_cells, $summary_list, $buffer);
    }

    # summary lines
    if ($self->unsafe_get('summary_line_type')) {
	_render_row($summary_lines, $list, $buffer);
    }

    $$buffer .= "\n</table>" if $self->get_or_default('end_tag', 1);
    return;
}

#=PRIVATE METHODS

# _get_cell(Bivio::Biz::ListModel list, string col, hash_ref attrs) : Bivio::UI::HTML::Widget
#
# Returns the widget for the specified cell. The list model is used for
# column metadata which may be used to construct a widget.
#
sub _get_cell {
    my($self, $list, $col, $attrs) = @_;

    my($cell);
    # see if widget is already provided
    if ($attrs->{column_widget}) {
	$cell = $attrs->{column_widget};
	$cell->put(%$attrs);
    }
    elsif ($col eq '') {
#TODO: optimize, could share instances with common span
	$cell =  Bivio::UI::HTML::Widget::Join->new({
	    values => ['&nbsp;'],
	    column_span => $attrs->{column_span} || 1,
	});
    }
    else {
	my($type) = $list->get_field_type($col);
	$cell = Bivio::UI::HTML::WidgetFactory->create(
		ref($list).'.'.$col, $attrs);
	unless ($cell->has_keys('column_summarize')) {
	    $cell->put(column_summarize => UNIVERSAL::isa($type,
		    'Bivio::Type::Amount'));
	}
    }
    _initialize_widget($self, $cell);
    return $cell;
}

# _get_column_count(array_ref cells) : int
#
# Returns the number of columns spanned by the specified cells.
#
sub _get_column_count {
    my($cells) = @_;
    my($count) = 0;
    foreach my $cell (@$cells) {
	$count += $cell->get_or_default('column_span', 1);
    }
    return $count;
}

# _get_enabled_widgets(Bivio::UI::HTML::Widget::Table self, any source) : array
#
# Returns the heading, cell, summary, and line widgets which are currently
# enabled.
#
sub _get_enabled_widgets {
    my($self, $source) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($all_headings) = $fields->{headings};
    my($all_cells) = $fields->{cells};
    my($all_summary_cells) = $fields->{summary_cells};
    my($all_summary_lines) = $fields->{summary_lines};

    my($enabler) = $self->unsafe_get('column_enabler');
    my($headings) = [];
    my($cells) = [];
    my($summary_cells) = [];
    my($summary_lines) = [];
    my($control);

    # determine which columns to render
    my($columns) = $self->get('columns');
    for (my($i) = 0; $i < int(@$columns); $i++) {
        my($col) = $columns->[$i];
        if ($col) {
            if (defined($enabler)) {
                next unless $enabler->enable_column($col, $self);
            }
            elsif ($control = $all_cells->[$i]->unsafe_get('column_control')) {
                next unless $source->get_widget_value($control);
            }
        }
        push(@$headings, $all_headings->[$i]);
        push(@$cells, $all_cells->[$i]);
        push(@$summary_cells, $all_summary_cells->[$i]);
        push(@$summary_lines, $all_summary_lines->[$i]);
    }
    return ($headings, $cells, $summary_cells, $summary_lines);
}

# _get_heading(Bivio::Biz::ListModel list, string col, Bivio::UI::HTML::Widget cell, array_ref sort_fields) : Bivio::UI::HTML::Widget
#
# Returns the table heading widget for the specified column widget.
#
sub _get_heading {
    my($self, $list, $col, $cell, $sort_fields) = @_;

    my($label) = $cell->get_or_default('column_heading', $col);
    if ($label) {
	# try to get the heading label first
	my($hl) = $label;
	$hl =~ s/\s/_/g;
	$hl =~ s/\./_/;
	$hl = Bivio::UI::Label->unsafe_get_simple($hl.'_HEADING');

	if (defined($hl)) {
	    $label = $hl;
	}
	else {
	    # try the simple version
	    my($l) = $label;
	    $l =~ s/\s/_/g;
	    $label = Bivio::UI::Label->unsafe_get_simple($l);

	    # then without periods
	    $l =~ s/\./_/;
	    $label = Bivio::UI::Label->get_simple($l) unless defined($label);
	}
    }

    my($heading) = Bivio::UI::HTML::Widget::String->new({
        value => $label,
        string_font => 'table_heading',
    });
    if (defined($sort_fields) && @$sort_fields) {
        # Restriction: Main sort field must be identical to column field
        Bivio::IO::Alert->die($sort_fields->[0], ' ne ', $col,
                ': sort field must be identical to column field')
                    unless $sort_fields->[0] eq $col;
        $heading = $self->director([
            sub {
                my($sort_col) = shift->get_query->get('order_by')->[0];
                return $sort_col eq $col ? 1 : 0;
            }], {
                0 => $self->link($heading,
                        ['->format_uri_for_sort', $sort_fields]),
                1 => $self->director([
                    sub {
                        return shift->get_query->get('order_by')->[1];
                    }], {
                        0 => $self->join([
                            $self->link($heading, ['->format_uri_for_sort',
                                $sort_fields, 1]),
                            ' ',
                            $self->image('sort_up',
                                    'This column sorted in descending order')
                            ->put(align => 'BOTTOM'),
                            ]),
                        1 => $self->join([
                            $self->link($heading, ['->format_uri_for_sort',
                                $sort_fields, 0]),
                            ' ',
                            $self->image('sort_down',
                                    'This column sorted in ascending order')
                            ->put(align => 'BOTTOM'),
                        ]),
                    }),
            });
    }
    $heading->put(
            column_nowrap => 1,
            column_align => $cell->get_or_default('heading_align', 'S'),
            column_span => $cell->get_or_default('column_span', 1),
            heading_expand => $cell->unsafe_get('column_expand'),
           );
    _initialize_widget($self, $heading);
    return $heading;
}

# _get_summary_cell(Bivio::UI::HTML::Widget cell) : Bivio::UI::HTML::Widget
#
# Returns a widget which renders the summary widget for the specified column.
#
sub _get_summary_cell {
    my($self, $cell) = @_;

    if ($cell->get_or_default('column_summarize', 0)) {
	return $cell;
    }
#TODO: optimize, could share instances with common span
    my($blank_string) = Bivio::UI::HTML::Widget::Join->new({
	values => ['&nbsp;'],
	column_span => $cell->get_or_default('column_span', 1),
    });
    _initialize_widget($self, $blank_string);
    return $blank_string;
}

# _get_summary_line(Bivio::UI::HTML::Widget cell) : Bivio::UI::HTML::Widget
#
# Returns a widget which renders the summary line for the specified column.
#
sub _get_summary_line {
    my($self, $cell) = @_;

    my($widget);
    if ($cell->get_or_default('column_summarize', 0)
	    && $self->unsafe_get('summary_line_type')) {

	my($line_type) = $self->unsafe_get('summary_line_type');
	if ($line_type eq '-') {
#TODO: optimize, could share instances with common span
	    $widget =  Bivio::UI::HTML::Widget::LineCell->new({
		color => 'summary_line',
		column_align => 'N'
	    });
	}
	elsif ($line_type eq '=') {
#TODO: optimize, could share instances with common span
	    $widget = Bivio::UI::HTML::Widget::LineCell->new({
		color => 'summary_line',
		column_align => 'N',
		count => 2
	    });
	}
	else {
	    die("invalid summary_line_type $line_type");
	}
    }
    else {
#TODO: optimize, could share instances with common span
	$widget = Bivio::UI::HTML::Widget::String->new({
	    value => '',
	});
    }
    $widget->put(column_span => $cell->get_or_default('column_span', 1));
    _initialize_widget($self, $widget);
    return $widget;
}

# _initialize_widget(Bivio::UI::HTML::Widget widget)
#
# Initializes the specified widget.
#
sub _initialize_widget {
    my($self, $widget) = @_;

    $widget->put(parent => $self);
    $widget->initialize;
    my($column_prefix) = Bivio::UI::Align->as_html(
	    $widget->get_or_default('column_align', 'LEFT'));
    $column_prefix .= ' nowrap' if $widget->unsafe_get('column_nowrap');
    my($span) = $widget->get_or_default('column_span', 1);
    $column_prefix .= " colspan=$span" if $span != 1;
    $widget->put(column_prefix => $column_prefix);
    return;
}

# _render_row(array_ref cells, any source, string_ref buffer, string row_prefix, boolean fix_space)
#
# _render_row(array_ref cells, any source, string_ref buffer)
#
# Renders the specified set of widgets onto the output buffer.
# If fix_space is true, then empty strings will be rendered as '&nbsp;'.
#
sub _render_row {
    my($cells, $source, $buffer, $row_prefix, $fix_space) = @_;
    $row_prefix ||= "\n<tr>";
    $$buffer .= $row_prefix;
    foreach my $cell (@$cells) {
	$$buffer .= "\n<td" . $cell->get_or_default('column_prefix', '');
        $$buffer .= ' width="100%"'
                if $cell->get_or_default('heading_expand', 0);
        $$buffer .= '>';

	# Insert a "&nbsp;" if the widget doesn't render.  This
	# makes the table look nicer on certain browsers.
	my($start) = length($$buffer);
	$cell->render($source, $buffer);
	$$buffer .= '&nbsp;' if length($$buffer) == $start && $fix_space;
	$$buffer .= '</td>';
    }
    $$buffer .= "\n</tr>";
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
