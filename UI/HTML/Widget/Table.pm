# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Table;
use strict;
$Bivio::UI::HTML::Widget::Table::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::Table::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::Table - renders a ListModel in an html table

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Table;
    Bivio::UI::HTML::Widget::Table->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::Table::ISA = ('Bivio::UI::Widget');

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

=head1 REQUEST ATTRIBUTES

=over 4

=item I<source_name> : Bivio::Biz::ListModel

List we are rendering.  I<source_name> is a table attribute.

=item I<source_name>.table_max_rows : int

Maximum number of I<source_name> rows to render.

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
by looking up (simple list class, field).

Each column element is specified in one of the following forms:

Just the field name of the list model:

    <field_name>

or an array_ref with the field_ref as the first element and attributes
as subsequent elements:

    [
        <field_name>,
        {
            <attr1> => <value1>,
            ...
        },
    ]

or a hash_ref where one attribute is named I<field>, identifying the field:

    {
        field => <field_name>,
        <attr1> => <value1>,
        ...,
    }

or the empty string which will render as the empty cell:

    '',

=item empty_list_widget : Bivio::UI::Widget []

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

=item footer_row_widgets : array_ref []

Widgets which will be rendered as the last row in the table.

=item heading_font : font [table_heading]

Font to use for table headings.

=item heading_separator : boolean [show_headings]

A separator will separate the headings from the cells.  The color will be
C<table_separator>.

=item list_class : string (required)

The class name of the list model to be rendered. The list_class is used
to determine the column cell types for the table. The
C<Bivio::Biz::Model::> prefix will be inserted if need be.

=item odd_row_bgcolor : string [table_odd_row_bg]

The stripe color to use for odd rows as defined by
L<Bivio::UI::Color|Bivio::UI::Color>.  If the color is
undefined, no striping will occur.

=item repeat_headings : boolean [false]

If true, then heading rows are repeated every n rows where n is the page
size preference for the current user.

=item row_grouping_field : string

Groups the column coloring based on the changes in the specified field.
For example, transaction entries can be grouped by transaction id.

=item show_headings : boolean [true]

If true, then the column headings are rendered.

=item source_name : string [list_class] (get_request)

The name of the list model as it appears upon the request. This value will
default to the 'list_class' attribute if not defined.

=item start_tag : boolean [true]

If false, this widget won't render the C<&gt;TABLE&lt;>tag.

=item string_font : string [table_cell]

Font to use for rendering cells.

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

=item want_sorting : boolean [1]

Should column sorting be displayed?

=item width : string []

Set the width of the table explicitly.  I<expand> should be
used in most cases.

=back

=head1 COLUMN ATTRIBUTES

=over 4

=item column_align : string [LEFT]

How to align the value within the cell.  The allowed (case
insensitive) values are defined in
L<Bivio::UI::Align|Bivio::UI::Align>.
The value affects the C<ALIGN> and C<VALIGN> attributes of the C<TD> tag.
See also I<heading_align>.

=item column_control : value

A widget value which, if set, must be a true value to render the column.

=item column_enabler : UNIVERSAL

The object which determines which columns to dynamically enable.
If present, then the method:

  enable_column(string name, Bivio::UI::HTML::Widget::Table table) : boolean

will be invoked upon it prior to rendering the table to determine which
columns to display.

=item column_expand : boolean [false]

If true, the column will be C<width="100%">.

=item column_heading : string

=item column_heading : Bivio::UI::Widget

The heading label to use for the columns heading. By default, the column
name is used to look up the heading label.  The name of the label
is the I<column_heading> with C<_HEADING> appended.

If the heading is a widget, then it will be used to render the heading.

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

=item column_widget : Bivio::UI::Widget

The widget which will be used to render the column. By default the column
widget is based on the column's field type.

=item heading_align : string [S]

How to align the heading.
The value affects the C<ALIGN> and C<VALIGN> attributes of the C<TH> tag.

=back

=cut

#=IMPORTS
use Bivio::Biz::Model;
use Bivio::Die;
use Bivio::UI::Align;
use Bivio::UI::Color;
use Bivio::UI::HTML::ViewShortcuts;
use Bivio::UI::HTML::Widget::FormFieldError;
use Bivio::UI::HTML::Widget::LineCell;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::WidgetFactory;
use Bivio::UI::Widget::Join;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_INFINITY_ROWS) = 0x7fffffff;
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Table

=head2 static new(string list_class, array_ref columns) : Bivio::UI::HTML::Widget::Table

=head2 static new(string list_class, array_ref columns, hash_ref attributes) : Bivio::UI::HTML::Widget::Table

Creates a new Table widget.

=cut

sub new {
    my($proto, $list_class, $columns, $attributes) = @_;
    my($self) = ref($list_class) eq 'HASH'
	    ? Bivio::UI::Widget::new($proto, $list_class)
	    : Bivio::UI::Widget::new($proto, {
		list_class => $list_class,
		columns => $columns,
		($attributes ? %$attributes : ()),
	    });
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="create_cell"></a>

=head2 create_cell(Bivio::Biz::Model model, string col, hash_ref attrs) : Bivio::UI::Widget

Returns the widget for the specified cell. The model is used for
column metadata which may be used to construct a widget.

=cut

sub create_cell {
    my($self, $model, $col, $attrs) = @_;

    my($cell);
    # see if widget is already provided
    if ($attrs->{column_widget}) {
	$cell = $attrs->{column_widget};
	$cell->put(%$attrs);
    }
    elsif ($col eq '') {
#TODO: optimize, could share instances with common span
	$cell =  Bivio::UI::Widget::Join->new({
	    values => ['&nbsp;'],
	    column_span => $attrs->{column_span} || 1,
	});
    }
    else {
	my($use_list) = 0;
	my($need_error_widget) = 0;

	# if the source is a ListFormModel, use editable fields
	if (UNIVERSAL::isa($model, 'Bivio::Biz::ListFormModel')) {
	    $use_list = 1;
	    # We allow editing of all but primary keys
	    if ($model->has_fields($col) && $model->get_field_constraint($col)
		    != Bivio::SQL::Constraint->PRIMARY_KEY) {
		$need_error_widget = 1;
		$use_list = 0;
	    }
	}
	$model = $model->get_instance($model->get_list_class)
		if $use_list;
	my($type) = $model->get_field_type($col);
	$cell = Bivio::UI::HTML::WidgetFactory->create(
		ref($model).'.'.$col, $attrs);
	if ($need_error_widget) {
	    # wrap the cell, including an error widget
	    $cell = Bivio::UI::Widget::Join->new({
		# Need to copy attributes when putting Widget around $cell.
		%{$cell->get_shallow_copy},
		# Our attributes override, however.
		values => [
		    Bivio::UI::HTML::Widget::FormFieldError->new({
			field => $col,
		        label => $_VS->vs_text(
				$model->simple_package_name, $col),
		    }),
		    $cell,
		],
	    });
	}
	unless ($cell->has_keys('column_summarize')) {
	    $cell->put(column_summarize =>
		    UNIVERSAL::isa($type,'Bivio::Type::Number')
		    && ! UNIVERSAL::isa($type, 'Bivio::Type::Enum'));
	}
	$cell->put(column_use_list => $use_list);
    }
    $self->initialize_child_widget($cell);
    return $cell;
}

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
	    unless defined($self->unsafe_get('string_font'));

    my($columns) = $self->get('columns');
    my($lm) = $list;
    if ($list->isa('Bivio::Biz::ListFormModel')) {
        $lm = $list->get_info('list_class')->get_instance;
    }
    my($sort_columns) = $lm->get_info('order_by_names');
    my($want_sorting) = $self->get_or_default('want_sorting', 1);

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
	my($cell) = $self->create_cell($list, $col, $attrs);
	push(@$cells, $cell);

        # Can we sort on this column?
        my($sort_fields) = $cell->unsafe_get('column_order_by')
		|| [grep($col eq $_, @$sort_columns)]
                        if $want_sorting && defined($sort_columns);

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

    if ($self->unsafe_get('footer_row_widgets')) {
	foreach my $widget (@{$self->get('footer_row_widgets')}) {
	    $self->initialize_child_widget($widget);
	}
    }
    return;
}

=for html <a name="initialize_child_widget"></a>

=head2 initialize_child_widget(Bivio::UI::Widget widget)

Initializes the specified widget.

=cut

sub initialize_child_widget {
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

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the table upon the output buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $source->get_request;
    my($state) = _initialize_render_state($self, $source, $buffer);
    return unless $state;
    my($list) = $state->{list};

    _render_start($state) if $self->get_or_default('start_tag', 1);

#TODO: optimize, for static tables just compute this once in initialize
    _initialize_colspan($state);
    _render_row_with_colspan($state, 'title') if $fields->{title};
    _render_headings($state);

    # alternating row colors
    my($is_even_row) = 0;
    _initialize_row_prefixes($state);

    # Row counting
    my($list_size) = $_INFINITY_ROWS;
    if ($self->get_or_default('repeat_headings', 0)
	    && Bivio::IO::ClassLoader->is_loaded(
		    'Bivio::Biz::Model::Preferences')) {
	$list_size = Bivio::Biz::Model::Preferences->get_user_pref(
		$req, 'PAGE_SIZE');
    }
    my($max_rows) = $req->unsafe_get($state->{list_name}.'.table_max_rows');
    $max_rows = $_INFINITY_ROWS unless $max_rows && $max_rows > 0;
    my($row_count) = 0;

    my($prev_value);
    my($grouping_field) = $self->unsafe_get('row_grouping_field');
    $list->reset_cursor;
    while ($list->next_row) {

	$is_even_row = !$is_even_row
		if defined($grouping_field) && defined($prev_value)
			&& $prev_value != $list->get($grouping_field);

	$self->render_row($state->{cells}, $list, $buffer,
		$is_even_row ? $state->{even_row} : $state->{odd_row}, 1);

	if (defined($grouping_field)) {
	    $prev_value = $list->get($grouping_field);
	}
	else {
	    $is_even_row = !$is_even_row;
	}

	last if ++$row_count >= $max_rows;
	_render_headings($state) if $row_count % $list_size == 0;
    }

    _render_trailer($state);
    return;
}

=for html <a name="render_cell"></a>

=head2 render_cell(Bivio::UI::Widget cell, any source, string_ref buffer)

Draws the specified cell onto the output buffer.

=cut

sub render_cell {
    my($self, $cell, $source, $buffer) = @_;
    $source = $source->get_list_model
	    if $cell->unsafe_get('column_use_list');
    $cell->render($source, $buffer);
    return;
}

=for html <a name="render_row"></a>

=head2 render_row(array_ref cells, any source, string_ref buffer)

=head2 render_row(array_ref cells, any source, string_ref buffer, string row_prefix, boolean in_list)

Renders the specified set of widgets onto the output buffer.
If in_list is true, then empty strings will be rendered as '&nbsp;'.

=cut

sub render_row {
    my($self, $cells, $source, $buffer, $row_prefix, $in_list) = @_;
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
	$self->render_cell($cell, $source, $buffer);
	$$buffer .= '&nbsp;' if length($$buffer) == $start && $in_list;
	$$buffer .= '</td>';
    }
    $$buffer .= "\n</tr>";
    return;
}

#=PRIVATE METHODS

# _get_heading(Bivio::Biz::ListModel list, string col, Bivio::UI::Widget cell, array_ref sort_fields) : Bivio::UI::Widget
#
# Returns the table heading widget for the specified column widget.
#
sub _get_heading {
    my($self, $list, $col, $cell, $sort_fields) = @_;

    my($heading) = $cell->get_or_default('column_heading', $col);

    unless (UNIVERSAL::isa($heading, 'Bivio::UI::Widget')) {
	# wrap it in a string widget
	$heading = Bivio::UI::HTML::Widget::String->new({
	    value => length($heading)
	    ? $_VS->vs_text($list->simple_package_name, $heading) : $heading,
	    string_font => $self->get_or_default(
		    'heading_font', 'table_heading'),
	});
    }

    if (defined($sort_fields) && @$sort_fields) {
        $heading = $_VS->vs_director([
            Bivio::Die->eval_or_die("sub {
                my(\$sort_col) = shift->get_query->get('order_by')->[0];
                return \$sort_col eq '$sort_fields->[0]' ? 1 : 0;
            }")], {
                0 => $_VS->vs_link($heading,
                        ['->format_uri_for_sort', undef, $sort_fields]),
                1 => $_VS->vs_director([
                    sub {
                        return shift->get_query->get('order_by')->[1];
                    }], {
                        0 => $_VS->vs_join([
                            $_VS->vs_link($heading, ['->format_uri_for_sort',
				undef, $sort_fields, 1]),
                            ' ',
                            $_VS->vs_image('sort_up',
                                    'This column sorted in descending order')
                            ->put(align => 'BOTTOM'),
                            ]),
                        1 => $_VS->vs_join([
                            $_VS->vs_link($heading, ['->format_uri_for_sort',
				undef, $sort_fields, 0]),
                            ' ',
                            $_VS->vs_image('sort_down',
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
    $self->initialize_child_widget($heading);
    return $heading;
}

# _get_summary_cell(Bivio::UI::Widget cell) : Bivio::UI::Widget
#
# Returns a widget which renders the summary widget for the specified column.
#
sub _get_summary_cell {
    my($self, $cell) = @_;

    if ($cell->get_or_default('column_summarize', 0)) {
	return $cell;
    }
#TODO: optimize, could share instances with common span
    my($blank_string) = Bivio::UI::Widget::Join->new({
	values => ['&nbsp;'],
	column_span => $cell->get_or_default('column_span', 1),
    });
    $self->initialize_child_widget($blank_string);
    return $blank_string;
}

# _get_summary_line(Bivio::UI::Widget cell) : Bivio::UI::Widget
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
    $self->initialize_child_widget($widget);
    return $widget;
}

# _initialize_colspan(hash_ref state)
#
# Initializes "colspan" to the number of columns spanned by the
# specified cells.
#
sub _initialize_colspan {
    my($state) = @_;
    my($count) = 0;
    foreach my $cell (@{$state->{cells}}) {
	$count += $cell->get_or_default('column_span', 1);
    }
    $state->{colspan} = $count;
    return;
}

# _initialize_render_state(Bivio::UI::HTML::Widget::Table self, any source, string_ref buffer) : hash_ref
#
# Returns the heading, cell, summary, and line widgets which are currently
# enabled.
#
sub _initialize_render_state {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $source->get_request;
    my($list_name) = $self->get('source_name');
    my($list) = $req->get($list_name);

    # check for an empty list
    if ($fields->{empty_list_widget} && $list->get_result_set_size == 0) {
	$fields->{empty_list_widget}->render($source, $buffer);
	return undef;
    }

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
                next unless $source->get_widget_value(@$control);
            }
        }
        push(@$headings, $all_headings->[$i]);
        push(@$cells, $all_cells->[$i]);
        push(@$summary_cells, $all_summary_cells->[$i]);
        push(@$summary_lines, $all_summary_lines->[$i]);
    }
    return {
	self => $self,
	fields => $fields,
	source => $source,
	buffer => $buffer,
	req => $req,
	list => $list,
	list_name => $list_name,
	headings => $headings,
	cells => $cells,
	summary_cells => $summary_cells,
	summary_lines => $summary_lines,
    };
}

# _initialize_row_prefixes(hash_ref state)
#
# Initializes even_row and odd_row row prefixes.
#
sub _initialize_row_prefixes {
    my($state) = @_;
    $state->{odd_row} = "\n<tr"
	    .Bivio::UI::Color->format_html(
		    $state->{self}->get_or_default('odd_row_bgcolor',
			    'table_odd_row_bg'),
		    'bgcolor', $state->{req}).'>';
    $state->{even_row} = "\n<tr"
	    .Bivio::UI::Color->format_html(
		    $state->{self}->get_or_default('even_row_bgcolor',
			    'table_even_row_bg'),
		    'bgcolor', $state->{req}).'>';
    return;
}

# _render_headings(hash_ref state)
#
# Renders the headings.  Checks show_headings and heading_separator.
#
sub _render_headings {
    my($state) = @_;
    unless (defined($state->{show_headings})) {
	$state->{show_headings} = $state->{self}
		->get_or_default('show_headings', 1);
	$state->{heading_separator} = $state->{self}
		->get_or_default('heading_separator', $state->{show_headings});
    }
    $state->{self}->render_row($state->{headings},
	    $state->{list}, $state->{buffer}) if $state->{show_headings};
    _render_row_with_colspan($state, 'separator')
	    if $state->{heading_separator};
    return;
}

# _render_row_with_colspan(hash_ref state, string widget_name)
#
# Renders a widget (currently only 'separator' or 'title') in a
# row of its own.
#
sub _render_row_with_colspan {
    my($state, $widget_name) = @_;
    my($buffer) = $state->{buffer};
    $$buffer .= "\n<tr><td colspan=".$state->{colspan}.'>';
    $state->{fields}->{$widget_name}->render($state->{list}, $buffer);
    $$buffer .= "</td>\n</tr>",
    return;
}

# _render_start(hash_ref state)
#
# Renders start tag of table.
#
sub _render_start {
    my($state) = @_;
    my($buffer) = $state->{buffer};
    $$buffer .= $state->{fields}->{table_prefix};
    $$buffer .= Bivio::UI::Align->as_html(
	    $state->{self}->get_or_default('align',
		    Bivio::UI::HTML->get_value('table_default_align',
			    $state->{req})));

    if ($state->{self}->unsafe_get('expand')) {
	$$buffer .= Bivio::UI::HTML->get_value('page_left_margin',
		$state->{req})
		? ' width="95%"' : ' width="100%"';
    }
    elsif (my $width = $state->{self}->unsafe_get('width')) {
	$$buffer .= ' width="'.$width.'"';
    }
    $$buffer .= '>';
    return;
}

# _render_trailer(hash_ref state)
#
# Renders footer, trailing_separator, summary, and end_tag.
#
sub _render_trailer {
    my($state) = @_;
    my($self) = $state->{self};
    $self->render_row($self->get('footer_row_widgets'),
	    $state->{list}, $state->{buffer})
	    if $self->unsafe_get('footer_row_widgets');

    _render_row_with_colspan($state, 'separator')
	    if $self->unsafe_get('trailing_separator');

    $self->render_row($state->{summary_cells},
	    $state->{list}->get_summary, $state->{buffer})
	    if $self->get_or_default('summarize',
		    $self->unsafe_get('summary_line_type') ? 1 : 0);

    $self->render_row($state->{summary_lines}, $state->{list},
	    $state->{buffer})
	    if $self->unsafe_get('summary_line_type');

    ${$state->{buffer}} .= "\n</table>" if $self->get_or_default('end_tag', 1);
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
