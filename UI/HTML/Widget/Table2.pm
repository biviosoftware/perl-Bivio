# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Table2;
use strict;
$Bivio::UI::HTML::Widget::Table2::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Table2 - renders a ListModel in an html table

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Table2;
    Bivio::UI::HTML::Widget::Table2->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Table2::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Table2> renders a
L<Bivio::Biz::ListModel|Bivio::Biz::ListModel> in a table.

=head1 TABLE ATTRIBUTES

=over 4

=item align : string [CENTER]

How to align the table.  The allowed (case
insensitive) values are defined in
L<Bivio::UI::Align|Bivio::UI::Align>.
The value affects the C<ALIGN> attributes of the C<TABLE> tag.

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

=item column_control_hash : string

Is the name of an attribute on I<source> which maps all columns to
a boolean value.  If the boolean is true, the column will be rendered.

=item column_enabler : UNIVERSAL

The object which determines which columns to dynamically enable.
If present, then the method:

  enable_column(string name, Bivio::UI::HTML::Widget::Table2 table) : boolean

will be invoked upon it prior to rendering the table to determine which
columns to display.

=item empty_list_widget : Bivio::UI::HTML::Widget []

If set, the widget to display instead of the table when the
list_model is empty.

The I<source> will be the original source, not the list_model.

If not set, displays an empty table (with headers).

=item end_tag : boolean [true]

If false, this widget won't render the C<&gt;/TABLE&lt;> tag.

=item list_class : string (required)

The class name of the list model to be rendered. The list_class is used
to determine the column cell types for the table. The
C<Bivio::Biz::Model::> prefix will be inserted if need be.

=item show_headings : boolean [true]

If true, then the column headings are rendered.

=item source_name : string

The name of the list model as it appears upon the request. This value will
default to the 'list_class' attribute if not defined.

=item start_tag : boolean [true]

If false, this widget won't render the C<&gt;TABLE&lt;>tag.

=item summarize : boolean [false]

If true, the list's summary model will be rendered.

=item summary_line_type : string

The type of summary line to render.
If defined, valid types are '-' for a single line, '=' for a double line.

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

=item column_heading : string

The heading label to use for the columns heading. By default, the column
name is used to look up the heading label.  The name of the label
is the I<column_heading> with C<_HEADING> appended.

=item field : string

Name of the column.  By default, it is the positional name.

=item column_nowrap : boolean [false]

If true, the column won't wrap text.

=item column_span : int [1]

The value for the C<COLSPAN> tag, which is not inserted if C<1>.

=item column_summarize : boolean

Determines whether the specified cell will be summarized. Only applies to
numeric columns. By default, numeric columns always summarize.

=item column_widget : Bivio::UI::HTML::Widget

The widget which will be used to render the column. By default the column
widget is based on the column's field type.

=back

=cut

#=IMPORTS

use Bivio::Biz::Model;
use Bivio::UI::Align;
use Bivio::UI::Color;
use Bivio::UI::HTML::Widget::AmountCell;
use Bivio::UI::HTML::Widget::DateTime;
use Bivio::UI::HTML::Widget::Enum;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::LineCell;
use Bivio::UI::HTML::Widget::MailTo;
use Bivio::UI::HTML::Widget::PercentCell;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::Icon;
use Bivio::UI::Label;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Table2

Creates a new Table2 widget.

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

    my($columns) = $self->get('columns');

#TODO: optimize, don't create summary widgets unless they are needed

    # create widgets for each heading, column, and summar
    my($cells) = [];
    my($headings) = [];
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
	push(@$headings, _get_heading($self, $col, $cell));
	push(@$summary_cells, _get_summary_cell($self, $cell));
	push(@$summary_lines, _get_summary_line($self, $cell));
    }
    $fields->{headings} = $headings;
    $fields->{cells} = $cells;
    $fields->{summary_lines} = $summary_lines;
    $fields->{summary_cells} = $summary_cells;

    # alternating row colors
    $fields->{odd_row} = "\n<tr>";
    $fields->{even_row} = "\n<tr"
	    .Bivio::UI::Color->as_html_bg('table_stripe_bg').'>';

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

    $fields->{table_prefix} = "\n<table border=0 cellspacing=0 cellpadding=5 "
	    ."align=".Bivio::UI::Align->as_html(
		    $self->get_or_default('align', 'center')).'>';
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the table upon the output buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($list) = $source->get($self->get('source_name'));

    # check for an empty list
    return $fields->{empty_list_widget}->render($source, $buffer)
	    if $fields->{empty_list_widget}
		    && $list->get_result_set_size == 0;

    my($headings, $cells, $summary_cells, $summary_lines) =
	    _get_enabled_widgets($self, $source);

    $$buffer .= $fields->{table_prefix}
	    if $self->get_or_default('start_tag', 1);

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
    my($even_row) = 0;
    while ($list->next_row) {
	_render_row($cells, $list, $buffer,
		$fields->{$even_row ? 'even_row' : 'odd_row'}, 1);
	$even_row = ! $even_row;
    }

    # separator
    if ($self->unsafe_get('trailing_separator')) {
	$$buffer .= "\n<tr><td colspan=$colspan>";
	$fields->{separator}->render($list, $buffer);
	$$buffer .= "</td>\n</tr>",
    }

    # summary
    if ($self->unsafe_get('summarize')) {
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

# _create_cell_widget(string field, string type, hash_ref attrs) : Bivio::UI::HTML::Widget
#
# Creates a widget which can render the specified type.
#
sub _create_cell_widget {
    my($field, $type, $attrs) = @_;

    if ($field =~ /percent/) {
	return Bivio::UI::HTML::Widget::PercentCell->new({
	    field => $field,
	    %$attrs,
	});
    }

#TODO: should check if the list class "can()" format_name()
    if ($field eq 'RealmOwner.name') {
	return Bivio::UI::HTML::Widget::String->new({
	    value => ['->format_name'],
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Amount')) {
	return Bivio::UI::HTML::Widget::AmountCell->new({
	    field => $field,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::DateTime')) {
	return Bivio::UI::HTML::Widget::DateTime->new({
	    mode => 'DATE',
	    column_align => 'E',
	    value => [$field],
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Enum')) {
	return Bivio::UI::HTML::Widget::Enum->new({
	    field => $field,
	    %$attrs,
	});
    }
    if (UNIVERSAL::isa($type, 'Bivio::Type::Email')) {
	return Bivio::UI::HTML::Widget::MailTo->new({
	    email => [$field],
	    %$attrs,
	});
    }

    # Numbers are just right adjusted strings.  Falls through
    if (UNIVERSAL::isa($type, 'Bivio::Type::Number')) {
	$attrs->{column_align} = 'right' unless $attrs->{column_align}
    }

    # default type is string
    return Bivio::UI::HTML::Widget::String->new({
	value => [$field],
	string_font => 'table_cell',
	%$attrs,
    });
}

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
	$cell = _create_cell_widget($col, $type, $attrs);
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

# _get_enabled_widgets(Bivio::UI::HTML::Widget::Table2 self, any source) : array
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
    unless ($enabler) {
	# The enabler is a hash
	my($a) = $self->unsafe_get('column_control_hash');
	$enabler = $source->get($a) if $a;
    }
    if (ref($enabler)) {

	my($headings) = [];
	my($cells) = [];
	my($summary_cells) = [];
	my($summary_lines) = [];

	# determine which columns to render
	my($columns) = $self->get('columns');
	for (my($i) = 0; $i < int(@$columns); $i++) {
	    my($col) = $columns->[$i];
	    if ($col) {
		# The enabler is a hash
		if (ref($enabler) eq 'HASH') {
		    unless ($enabler->{$col}) {
			Bivio::IO::Alert->die('column_control_hash (',
				$self->unsafe_get('column_control_hash'),
				') missing column:', $col)
				    unless defined($enabler->{$col});
			next;
		    }
		}
		else {
		    next unless $enabler->enable_column($col, $self);
		}
	    }
	    push(@$headings, $all_headings->[$i]);
	    push(@$cells, $all_cells->[$i]);
	    push(@$summary_cells, $all_summary_cells->[$i]);
	    push(@$summary_lines, $all_summary_lines->[$i]);
	}
	return ($headings, $cells, $summary_cells, $summary_lines);
    }
    return ($all_headings, $all_cells, $all_summary_cells, $all_summary_lines);
}

# _get_heading(string col, Bivio::UI::HTML::Widget cell) : Bivio::UI::HTML::Widget
#
# Returns the table heading widget for the specified column widget.
#
sub _get_heading {
    my($self, $col, $cell) = @_;

    my($label) = $cell->get_or_default('column_heading', $col);
    if ($label) {
	$label .= '_HEADING';
	$label =~ s/\s/_/g;
	$label =~ s/\./_/;
	$label = Bivio::UI::Label->get_simple($label);
    }
    my($heading) = Bivio::UI::HTML::Widget::String->new({
	value => $label,
	string_font => 'table_heading',
	column_align => 'S',
	column_span => $cell->get_or_default('column_span', 1),
    });
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
	$$buffer .= "\n<td".$cell->get_or_default('column_prefix', '').'>';

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
