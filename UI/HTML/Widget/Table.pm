# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Table;
use strict;
use Bivio::Base 'HTMLWidget.TableBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

# C<Bivio::UI::HTML::Widget::Table> renders a
# L<Bivio::Biz::ListModel|Bivio::Biz::ListModel> in a table.
#
# Bivio::UI::HTML.table_default_align : string
#
# Default table alignment name.
#
# Bivio::UI::HTML.page_left_margin : int
#
# If greater than zero, expand to "95%".  Otherwise, "100%"?
#
# I<source_name> : Bivio::Biz::ListModel
#
# List we are rendering.  I<source_name> is a table attribute.
#
# I<source_name>.table_max_rows : int
# table_max_rows : int
#
# Maximum number of I<source_name> rows to render.
#
# align : string [Bivio::UI::HTML.table_align]
#
# How to align the table.  The allowed (case
# insensitive) values are defined in
# L<Bivio::UI::Align|Bivio::UI::Align>.
# The value affects the C<ALIGN> attributes of the C<TABLE> tag.
#
# columns : array_ref (required)
#
# The column names to display, in order. Column headings will be assigned
# by looking up (simple list class, field).
#
# Each column element is specified in one of the following forms:
#
# Just the field name of the list model:
#
#     <field_name>
#
# or an array_ref with the field_ref as the first element and attributes
# as subsequent elements:
#
#     [
#         <field_name>,
#         {
#             <attr1> => <value1>,
#             ...
#         },
#     ]
#
# or a hash_ref where one attribute is named I<field>, identifying the field:
#
#     {
#         field => <field_name>,
#         <attr1> => <value1>,
#         ...,
#     }
#
# or the empty string which will render as the empty cell:
#
#     '',
#
# empty_list_widget : Bivio::UI::Widget []
#
# If set, the widget to display instead of the table when the
# list_model is empty.
#
# The I<source> will be the original source, not the list_model.
#
# If not set, displays an empty table (with headers).
#
# even_row_bgcolor : string [table_even_row_bg]
#
# The stripe color to use for even rows as defined by
# L<Bivio::UI::Color|Bivio::UI::Color>.  If the color is
# undefined, no striping will occur.
#
# even_row_class : any []
#
# Class applied applied to even rows.
#
# footer_row_widgets : array_ref []
#
# Widgets which will be rendered as the last row in the table.
#
# heading_align : string [S]
#
# How to align the heading.
# The value affects the C<ALIGN> and C<VALIGN> attributes of the C<TH> tag.
#
# May be specified on the table or overriden by the cell.
#
# heading_font : font [table_heading]
#
# Font to use for table headings.
#
# May be specified on the table or overriden by the cell.
#
# heading_separator : boolean [show_headings]
#
# A separator will separate the headings from the cells.  The color will be
# C<table_separator>.
#
# heading_separator_row_class : any []
#
# HTML class for heading_separator.
#
# list_class : string (required)
#
# The class name of the list model to be rendered. The list_class is used
# to determine the column cell types for the table. The
# C<Bivio::Biz::Model::> prefix will be inserted if need be.
#
# odd_row_bgcolor : string [table_odd_row_bg]
#
# The stripe color to use for odd rows as defined by
# L<Bivio::UI::Color|Bivio::UI::Color>.  If the color is
# undefined, no striping will occur.
#
# odd_row_class : any []
#
# Class applied applied to odd rows.
#
# repeat_headings : boolean [false]
#
# If true, then heading rows are repeated every n rows where n is the page
# size preference for the current user.
#
# row_grouping_field : string
#
# Groups the column coloring based on the changes in the specified field.
# For example, transaction entries can be grouped by transaction id.
#
# row_bgcolor : array_ref []
#
# Widget value which returns row color.  If returns undef, uses default
# colors (even_row_bgcolor or odd_row_bgcolor).
#
# show_headings : boolean [true]
#
# If true, then the column headings are rendered.
#
# source_name : string [list_class] (get_request)
#
# The name of the list model as it appears upon the request. This value will
# default to the 'list_class' attribute if not defined.
#
# source_name : array_ref [] (source)
#
# The widget value from I<source> that returns the model to render.  Note that
# I<table_max_rows> feature uses the ref($list) for list_name (see below).
#
# Using this attribute allows lists of lists.
#
# string_font : string [table_cell]
#
# Font to use for rendering cells.
#
# summarize : boolean [false]
#
# If true, the list's summary model will be rendered.  Will be true
# implicitly, if I<summary_line_type> is set.
#
# summary_only : boolean [false]
#
# If true, render only the list's summary model.
#
# summary_line_class : string
#
# Class for summary lines.  Must be a string or undef, and if set,
# must not have I<summary_line_type>.
#
# summary_line_type : string
#
# The type of summary line to render.
# If defined, valid types are '-' for a single line, '=' for a double line.
# If true, sets I<summarize> to true if I<summarize> is not already set.
#
# title : string
#
# The name of the table.
#
# title_row_class : string
#
# HTML class for title.
#
# trailing_separator : boolean [false]
#
# A separator will separate the cells from the summary.  The color will be
# C<table_separator>.
#
# trailing_separator_row_class : any []
#
# HTML class for trailing_separator.
#
# want_sorting : boolean [1]
#
# Should column sorting be displayed?
#
# width : string []
#
# Set the width of the table explicitly.  I<expand> should be
# used in most cases.
#
# before_row : Bivio::UI::Widget
#
# An optional widget which will be rendered before every row.
#
#
#
#
# column_align : string [LEFT]
#
# How to align the value within the cell.  The allowed (case
# insensitive) values are defined in
# L<Bivio::UI::Align|Bivio::UI::Align>.
# The value affects the C<ALIGN> and C<VALIGN> attributes of the C<TD> tag.
# See also I<heading_align>.
#
# column_bgcolor : any []
#
# Sets the cell background color.
#
# column_height : any []
#
# Sets the cell height.
#
# column_data_class : any []
#
# HTML class for column data cells.
#
# column_control : value
#
# A widget value which, if set, must be a true value to render the column.
#
# column_enabler : UNIVERSAL
#
# The object which determines which columns to dynamically enable.
# If present, then the method:
#
#   enable_column(string name, Bivio::UI::HTML::Widget::Table table) : boolean
#
# will be invoked upon it prior to rendering the table to determine which
# columns to display.
#
# column_expand : boolean [false]
#
# If true, the column will be C<width="100%">.
#
# column_footer_class : any []
#
# HTML class for column footer.
#
# column_heading : string
#
# column_heading : Bivio::UI::Widget
#
# The heading label to use for the columns heading. By default, the column
# name is used to look up the heading label.  The name of the label
# is the I<column_heading> with C<_HEADING> appended.
#
# If the heading is a widget, then it will be used to render the heading.
#
# column_heading : string_ref
#
# B<DEPRECATED>.
#
# The literal text of the label.  The indirected value will be
# looked up once and used.  This avoids a second lookup.  Only
# used by DescriptivePageForm.
#
# column_heading_class : any []
#
# HTML class for column heading.
#
# column_width : string
#
# Set the width of the column explicitly.  I<column_expand> should be
# used in most cases.
#
# field : string
#
# Name of the column.  By default, it is the positional name.
#
# column_nowrap : boolean [false]
#
# If true, the column won't wrap text.
#
# column_order_by : array_ref
#
# The list of sort fields to use when sorting on this column.
# By default, this is the field name of the column.
#
# column_span : int [1]
#
# The value for the C<COLSPAN> tag, which is not inserted if C<1>.
#
# column_summarize : boolean
#
# Determines whether the specified cell will be summarized. Only applies to
# numeric columns. By default, numeric columns always summarize.
#
# column_summary_value : string ['&nbsp;']
#
# Value to use for the summary cell of a column that isn't summarized.
#
# column_want_error_widget : boolean [see create_cell]
#
# Force creation of error widget around the cell if true.
#
# column_widget : Bivio::UI::Widget
#
# The widget which will be used to render the column. By default the column
# widget is based on the column's field type.
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VS) = b_use('UIHTML.ViewShortcuts');
my($_WF) = b_use('UIHTML.WidgetFactory');
my($_A) = b_use('UI.Align');
my($_C) = b_use('UI.Color');
my($_TRC) = b_use('UI.TableRowClass');
my($_INFINITY_ROWS) = 0x7fffffff;
my($_IDI) = __PACKAGE__->instance_data_index;
my($_M) = b_use('Biz.Model');
my($_IOA) = b_use('IO.Alert');
my($_HTML) = b_use('Bivio.HTML');
my($_RT) = b_use('Model.RowTag');

sub create_cell {
    my($self, $model, $col, $attrs) = @_;
    my($cell);
    my($need_error_widget) = 0;
    # see if widget is already provided
    if ($attrs->{column_widget}) {
	$cell = $attrs->{column_widget};
	$cell->put(%$attrs);
    }
    elsif ($col eq '') {
	$cell = Join(['&nbsp;'], {
	    column_span => $attrs->{column_span} || 1,
	});
    }
    else {
	my($use_list) = 0;
	if (UNIVERSAL::isa($model, 'Bivio::Biz::ListFormModel')) {
	    $use_list = 1;
	    if ($model->has_fields($col)
	        && !$model->get_field_constraint($col)->eq_primary_key
	    ) {
		$need_error_widget = 1;
		$use_list = 0;
	    }
	}
	$model = $model->get_list_model
	    if $use_list;
	my($type) = $model->get_field_type($col);
	$cell = $_WF->create(
	    $model->simple_package_name . '.' . $col, $attrs);
	unless ($cell->has_keys('column_summarize')) {
	    $cell->put(column_summarize =>
		UNIVERSAL::isa($type,'Bivio::Type::Number')
		&& ! UNIVERSAL::isa($type, 'Bivio::Type::Enum')
		&& ! UNIVERSAL::isa($type, 'Bivio::Type::PrimaryId')
		? 1 : 0);
	}
	$cell->put(column_use_list => $use_list);
    }
    if ($cell->get_or_default(
	'column_want_error_widget', $need_error_widget)) {
	# wrap the cell, including an error widget
	$cell = $_VS->vs_new('Join', {
	    # Need to copy attributes when putting Widget around $cell.
	    %{$cell->get_shallow_copy},
	    # Our attributes override, however.
	    values => [
		$_VS->vs_new('FormFieldError', {
		    field => $col,
		    label => $_VS->vs_text($model->simple_package_name, $col),
		}),
		$cell,
	    ],
	});
    }
    $self->initialize_child_widget($cell);
    return $cell;
}

sub get_render_state {
    # (self, any, string_ref) : hash_ref
    # B<Not for general use.>
    #
    # Returns the heading, cell, summary, and line widgets which are currently
    # enabled.
    #
    # Returns I<undef> if the table has no rows and there is an
    # I<empty_list_widget>.
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($list_name) = $self->get('source_name');
    my($list) = ref($list_name) ? $source->get_widget_value(@$list_name)
	: $req->get($list_name);
    $list_name = ref($list_name) ? ref($list) : $list_name;

    # check for an empty list
    if ($list->get_result_set_size == 0
        && $self->unsafe_get('empty_list_widget')) {
	$self->unsafe_render_attr('empty_list_widget', $source, $buffer);
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
        if ($col && defined($enabler)) {
	    next unless $enabler->enable_column($col, $self);
        }
	if ($control = $all_cells->[$i]->unsafe_get('column_control')) {
	    next unless $self->unsafe_resolve_widget_value($control, $source);
	}
        push(@$headings, $all_headings->[$i]);
        push(@$cells, $all_cells->[$i]);
        push(@$summary_cells, $all_summary_cells->[$i]);
        push(@$summary_lines, $all_summary_lines->[$i]);
    }
    my($state) = {
	self => $self,
	fields => $fields,
	source => $source,
	buffer => $buffer,
	req => $req,
	list => $list,
	list_name => $list_name,
	headings => $headings,
	cells => $self->get_or_default('summary_only', 0) ? undef : $cells,
	summary_cells =>
	    ($self->get_or_default('summarize',
		$self->unsafe_get('summary_line_type')
		    || $self->unsafe_get('summary_only') ? 1 : 0)
	    ? $summary_cells : undef),
	summary_lines => $summary_lines,
	show_headings => $self->get_or_default('show_headings', 1),
    };
    $state->{heading_separator} = $self->get_or_default(
	heading_separator => _xhtml($self, sub {$state->{show_headings}}, 0),
    );
    return $state;
}

sub initialize {
    my($self, $source) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{headings};
    my($list) = $_M->get_instance($self->get('list_class'));
    $self->put(source_name => $list->package_name)
	unless $self->has_keys('source_name');
    if ($source) {
	my($n) = $self->get('source_name');
	$list = ref($n) ? $source->get_widget_value(@$n)
	    : $source->req->get($n);
    }
    $self->put_unless_defined(string_font => 'table_cell');
    my($columns) = $self->get('columns');
    my($lm) = $list;
    $lm = $list->get_list_model
	if $list->isa('Bivio::Biz::ListFormModel');
    my($sort_cols) = $lm->get_info('order_by_names');
    my($want_sorting) = $self->get_or_default('want_sorting', 1);
    my($cells) = [];
    my($headings) = [];
    my($summary_cells) = [];
    my($summary_lines) = [];
    foreach my $col (@$columns) {
	my($attrs);
	if (ref($col) eq 'ARRAY') {
	    ($col, $attrs) = @$col;
	    $attrs->{field} = $col
		unless $attrs->{field};
	    $col = $attrs->{field}
		unless $col;
	}
	elsif (ref($col) eq 'HASH') {
	    $attrs = $col;
	    $col = $attrs->{field} || '';
	}
	else {
	    $attrs = {field => $col};
	}
	# ClassWrapper.TupleTag support
	$col = $attrs->{field} = $lm->get_field_info($col, 'name')
	    if $col && $lm->has_fields($col);
	my($cell) = $self->create_cell($list, $col, $attrs);
	push(@$cells, $cell);
	my($want_column_sorted) = defined($cell->unsafe_get('want_sorting'))
	    ? $cell->unsafe_get('want_sorting') : $want_sorting;
        my($sort);
	($sort = $cell->unsafe_get('column_order_by'))
	    || @{$sort = [grep($col eq $_, @$sort_cols)]}
	    || @{$sort = [grep($_ =~ /^$col(?:_lc|_sort)$/, @$sort_cols)]}
	    || ($sort = undef)
	    if $want_column_sorted && $sort_cols;
        push(@$headings, _get_heading($self, $lm, $col, $cell, $sort));
	push(@$summary_cells, _get_summary_cell($self, $cell));
	push(@$summary_lines, _get_summary_line($self, $cell));
    }
    $fields->{headings} = $headings;
    $fields->{cells} = $cells;
    $fields->{summary_lines} = $summary_lines;
    $fields->{summary_cells} = $summary_cells;
    my($title) = $self->unsafe_get('title');
    if (defined($title)) {
	$fields->{title} = $_VS->vs_new('Tag', 'DIV',
	    $_VS->vs_new('String', $title, 'table_heading'),
	        $self->unsafe_get('title_row_class') || ())
	    ->initialize_with_parent($self, $source);
    }

    # heading separator and summary
    foreach my $w (qw(heading trailing)) {
	$fields->{$w . '_separator'} = $_VS->vs_new('LineCell', {
	    height => 1,
	    color => 'table_separator',
	})->initialize_with_parent($self, $source);
    }
    $self->unsafe_initialize_attr('empty_list_widget', $source);
    $self->unsafe_initialize_attr('before_row', $source);
    foreach my $c (qw(
	even_row
	odd_row
        data_row
        footer_row
        heading_row
        heading_separator_row
        title_row
        trailing_separator_row
    )) {
	$self->initialize_attr($c . '_class', 'b_' . $c);
    }
    $_VS->vs_html_attrs_initialize(
	$self,
	undef,
        $source,
    );
    $self->initialize_html_attrs($source);
    foreach my $widget (@{$self->unsafe_get('footer_row_widgets') || []}) {
	$self->initialize_child_widget($widget, $source);
    }
    return;
}

sub initialize_child_widget {
    # (self, UI.Widget) : undef
    # Initializes the specified widget.
    my($self, $widget, $source) = @_;

    $widget->initialize_with_parent($self, $source);
    my($column_prefix) = '';
    _xhtml(
	$self,
	sub {
	    $column_prefix .= $_A->as_html(
		$widget->get_or_default('column_align', 'LEFT'));
	    $column_prefix .= ' nowrap="nowrap"'
		if $widget->unsafe_get('column_nowrap');
	    return;
        },
    );
    my($span) = $widget->get_or_default('column_span', 1);
    $column_prefix .= qq{ colspan="$span"}
	if $span != 1;
    $widget->put(column_prefix => $column_prefix);
    $_VS->vs_html_attrs_initialize(
	$widget,
	[qw(column_data_class column_footer_class column_heading_class)],
        $source,
    );
    return;
}

sub internal_as_string {
    # (self) : array
    # Returns the list model.
    #
    # See L<Bivio::UI::Widget::as_string|Bivio::UI::Widget/"as_string">.
    my($self) = @_;
    return $self->unsafe_get('list_class');
}

sub internal_new_args {
    # (proto, any, ...) : any
    # Implements positional argument parsing for L<new|"new">.
    my(undef, $list_class, $columns, $attributes) = @_;
    return '"list_class" must be a defined scalar'
	unless defined($list_class) && !ref($list_class);
    return '"columns" must be an array_ref'
	unless ref($columns) eq 'ARRAY';
    return {
	list_class => $list_class,
	columns => $columns,
	($attributes ? %$attributes : ()),
    };
}

sub new {
    # (proto, string, array_ref, hash_ref) : Widget.Table
    # (proto, hash_ref) : Widget.Table
    # Creates a new Table with I<list_class>, I<columns>, and optional
    # I<attributes>.
    #
    #
    # Creates a new Table widget with I<attributes>.
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

sub render {
    # (self, any, string_ref) : undef
    # Draws the table upon the output buffer.
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($state) = $self->get_render_state($source, $buffer);
    return unless $state;
    my($list) = $state->{list};

    ${$state->{buffer}} .= $self->render_start_tag($source);

#TODO: optimize, for static tables just compute this once in initialize
    _initialize_colspan($state);
    _render_row_with_colspan($state, 'title')
	if $fields->{title};
    _render_headings($state);

    # alternating row colors
    my($is_even_row) = 0;

    # Row counting
    my($list_size) = $_INFINITY_ROWS;
    $list_size = $_RT->new($req)->row_tag_get_for_auth_user('page_size')
        if $self->get_or_default('repeat_headings', 0);
    my($max_rows) = $req->unsafe_get($state->{list_name}.'.table_max_rows')
	|| $self->unsafe_get('table_max_rows');
    $max_rows = $_INFINITY_ROWS unless $max_rows && $max_rows > 0;
    my($row_count) = 0;

    my($prev_value);
    my($grouping_field) = $self->unsafe_get('row_grouping_field');
    $list->reset_cursor;
    while ($list->next_row) {
	my($grouping_value) = defined($grouping_field)
		? $list->get_list_model->get($grouping_field)
		: undef;

	$is_even_row = !$is_even_row
		if defined($grouping_field) && defined($prev_value)
			&& $prev_value ne $grouping_value;

	$self->render_row(
	    $state->{cells},
	    $list,
	    $buffer,
	    _row_prefix($state, $is_even_row),
	    $_TRC->DATA,
	);
	if (defined($grouping_field)) {
	    $prev_value = $grouping_value;
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

sub render_cell {
    # (self, UI.Widget, any, string_ref) : undef
    # Draws the specified cell onto the output buffer.
    my($self, $cell, $source, $buffer) = @_;
    $source = $source->get_list_model
	if $cell->unsafe_get('column_use_list');
    $cell->render($source, $buffer);
    return;
}

sub render_row {
    # (self, array_ref, any, string_ref, string, UI.TableRowClass) : undef
    # Renders the specified set of widgets onto the output buffer.
    # If in_list is true, then empty strings will be rendered as '&nbsp;'.
    my($self, $cells, $source, $buffer, $row_prefix, $class) = @_;
    my($req) = $self->get_request;
    _render_before_row($self, scalar(@$cells), $source, $buffer)
	unless $class == $_TRC->HEADING;
    $$buffer .= $row_prefix
	|| "\n<tr"
	. $_VS->vs_html_attrs_render_one(
	    $self, $source, lc($class->get_name) . '_row_class')
	. '>';
    foreach my $cell (@$cells) {
	$$buffer .= ($class == $_TRC->HEADING
	    ? "\n<th" : "\n<td")
	    . $cell->get_or_default('column_prefix', '')
	    . $_VS->vs_html_attrs_render_one(
		$cell, $source,
		'column_' . lc($class->get_name) . '_class');
	if ($cell->get_or_default('heading_expand', 0)) {
	    $$buffer .= ' width="100%"'
	}
	elsif ($cell->get_or_default('heading_width', 0)) {
	    $$buffer .= ' width="'.$cell->get('heading_width').'"';
	}
	my($bg);
	$$buffer .= $_C->format_html($bg, 'bgcolor', $req)
	    if $class == $_TRC->DATA
		&& $cell->unsafe_render_attr(
		    'column_bgcolor', $source, \$bg) && $bg;
	my($h) = $cell->render_simple_attr('column_height', $source);
	$$buffer .= qq{ height="$h"}
           if $class == $_TRC->DATA && $h;
        $$buffer .= '>';

	# Insert a "&nbsp;" if the widget doesn't render.  This
	# makes the table look nicer on certain browsers.
	my($start) = length($$buffer);
	$self->render_cell($cell, $source, $buffer);
	_xhtml(
	    $self,
	    sub {
		$$buffer .= '&nbsp;'
		    if length($$buffer) == $start
		    && $class == $_TRC->DATA;
	    },
	);
	$$buffer .= $class == $_TRC->HEADING
	    ? '</th>' : '</td>';
    }
    $$buffer .= "\n</tr>";
    return;
}

sub _get_heading {
    # (Biz.ListModel, string, UI.Widget, array_ref) : UI.Widget
    # Returns the table heading widget for the specified column widget.
    my($self, $list, $col, $cell, $sort_fields) = @_;
    my($heading) = $cell->get_or_default('column_heading', $col);
    $heading = $_VS->vs_new(
	'String',
	length($heading)
	    ? $_VS->vs_new(
		'Prose', $_VS->vs_text($list->simple_package_name, $heading))
	    : $heading,
	$cell->get_or_default(
	    'heading_font',
	    $self->get_or_default('heading_font', 'table_heading'),
	),
    ) unless UNIVERSAL::isa($heading, 'Bivio::UI::Widget');
    if (my $class = $cell->unsafe_get('column_heading_class')) {
	$heading->put(column_heading_class => $class);
    }
    $heading = $_VS->vs_new(
	'Link',
	$_VS->vs_new(
	    Join => [$heading, _sort_widget($self, $list, $sort_fields)]),
	[
	    '->format_uri_for_sort',
	    undef,
	    [sub {
		  my($o) = shift->get_query->get('order_by');
		  return $o->[0] eq shift(@_) ? $o->[1] ? 0 : 1 : undef;
	    }, $sort_fields->[0]],
	    @$sort_fields,
	],
	$cell->unsafe_get('column_heading_class') ? {
	    column_heading_class => $cell->get('column_heading_class'),
	} : (),
    ) if $sort_fields && @$sort_fields;
    $heading->put(
	column_align => $cell->get_or_default(
	    'heading_align',
	    $self->get_or_default('heading_align', 'S'),
	),
	column_span => $cell->get_or_default('column_span', 1),
	heading_expand => $cell->unsafe_get('column_expand'),
	heading_width => $cell->unsafe_get('column_width'),
    );
    $self->initialize_child_widget($heading);
    return $heading;
}

sub _get_summary_cell {
    # (UI.Widget) : UI.Widget
    # Returns a widget which renders the summary widget for the specified column.
    my($self, $cell) = @_;

    if ($cell->get_or_default('column_summarize', 0)) {
	return $cell;
    }
#TODO: optimize, could share instances with common span
    my($blank_string) = $_VS->vs_new('Join', {
	values => [$cell->get_or_default('column_summary_value', '&nbsp;')],
	column_span => $cell->get_or_default('column_span', 1),
    });
    $self->initialize_child_widget($blank_string);
    return $blank_string;
}

sub _get_summary_line {
    # (UI.Widget) : UI.Widget
    # Returns a widget which renders the summary line for the specified column.
    my($self, $cell) = @_;

    my($widget);
    my($type) = $self->unsafe_get('summary_line_type');
    my($class) = $self->unsafe_get('summary_line_class');
    if ($cell->get_or_default('column_summarize', 0) && ($type || $class)) {
	Bivio::Die->die(
	    $type, ' & ', $class,
	    ': may not have both summary_line_type and summary_line_class'
	) if $type && $class;
	$widget = $type
	    ? $_VS->vs_new('LineCell', {
		color => 'summary_line',
		column_align => 'N',
		count => $type eq '=' ? 2
		    : $type eq '-' ? 1
		    : Bivio::Die->die($type, 'invalid summary_line_type'),
	    })
	    : $_VS->vs_new('Tag', {
		tag => 'td',
		value => '',
		class => $class,
		tag_if_empty => 1,
	    });
    }
    else {
#TODO: optimize, could share instances with common span
	$widget = $_VS->vs_new('String', {
	    value => '',
	});
    }
    $widget->put(column_span => $cell->get_or_default('column_span', 1));
    $self->initialize_child_widget($widget);
    return $widget;
}

sub _initialize_colspan {
    # (hash_ref) : undef
    # Initializes "colspan" to the number of columns spanned by the
    # specified cells.
    my($state) = @_;
    my($count) = 0;
    foreach my $cell (@{$state->{cells}}) {
	$count += $cell->get_or_default('column_span', 1);
    }
    $state->{colspan} = $count;
    return;
}

sub _render_before_row {
    my($self, $cols, $source, $buffer) = @_;
    my($b) = '';
    $self->unsafe_render_attr('before_row', $source, \$b);
    $$buffer .= qq(\n<tr><td colspan="$cols">$b</td></tr>)
	if length($b);
    return;
}

sub _render_headings {
    # (hash_ref) : undef
    # Renders the headings.  Checks show_headings and heading_separator.
    my($state) = @_;
    $state->{self}->render_row($state->{headings},
	$state->{list}, $state->{buffer}, undef,
	$_TRC->HEADING)
	if $state->{show_headings};
    _render_row_with_colspan($state, 'heading_separator')
	if $state->{heading_separator};
    return;
}

sub _render_row_with_colspan {
    # (hash_ref, string) : undef
    # Renders a widget (currently only 'separator' or 'title') in a
    # row of its own.
    my($state, $widget_name) = @_;
    my($buffer) = $state->{buffer};
    $$buffer .= "\n<tr"
	. $_VS->vs_html_attrs_render_one(
	    @$state{qw(self source)}, $widget_name . '_row_class')
	. '><td colspan="' . $state->{colspan}
	.'">';
    $state->{fields}->{$widget_name}->render($state->{list}, $buffer);
    $$buffer .= "</td>\n</tr>";
    return;
}

sub _render_trailer {
    # (hash_ref) : undef
    # Renders footer, trailing_separator, summary, and end_tag.
    my($state) = @_;
    my($self) = $state->{self};
    $self->render_row($self->get('footer_row_widgets'),
	$state->{list}, $state->{buffer}, undef,
	$_TRC->FOOTER)
	if $self->unsafe_get('footer_row_widgets');

    _render_row_with_colspan($state, 'trailing_separator')
	if $self->unsafe_get('trailing_separator');

    $self->render_row(
	$state->{summary_cells},
	$state->{list}->get_summary, $state->{buffer}, undef,
	$_TRC->FOOTER,
    ) if $state->{summary_cells};

    $self->render_row($state->{summary_lines}, $state->{list},
	$state->{buffer}, undef,
	$_TRC->FOOTER)
	if $self->unsafe_get('summary_line_type');

    ${$state->{buffer}} .= $state->{self}->render_end_tag($state->{source});
    return;
}

sub _row_prefix {
    my($state, $is_even_row) = @_;
    my($color) = $state->{self}->render_simple_attr(
	'row_bgcolor', $state->{list});
    my($class) = join(
	' ',
	grep($_,
	    $state->{self}->render_simple_attr(
		'data_row_class',
		$state->{list},
	    ),
	    $state->{self}->render_simple_attr(
		$is_even_row ? 'even_row_class' : 'odd_row_class',
		$state->{list},
	    ),
	),
    );
    _xhtml(
	$state->{self},
	sub {
	    $color ||= ('table_' . ($is_even_row ? 'even' : 'odd') . '_row_bg');
	    return;
	},
    );
    return "\n<tr"
	. ($color ? $_C->format_html($color, 'bgcolor', $state->{req}) : '')
	. ($class ? ' class="' . $_HTML->escape_attr_value($class) . '"' : '')
	. '>';
}

sub _sort_widget {
    my($self, $list, $sort_fields) = @_;
    return $_VS->vs_new(
	'If',
	[sub {
	     shift->get_query->get('order_by')->[0] eq shift(@_);
	}, $sort_fields->[0]],
	_xhtml(
	    $self,
	    sub {
		return $_VS->vs_new(
		    'Join', [
			' ',
			$_VS->vs_new(
			    'Image',
			    [sub {
				 shift->get_query->get('order_by')->[1]
				     ? 'sort_down' : 'sort_up',
			    }],
			    undef,
			    {align => 'bottom'},
			),
		    ],
		);
	    },
	    sub {
		If(
		    [sub {shift->get_query->get('order_by')->[1]}],
		    map(
			SPAN(
			    Prose(
				vs_text($list->simple_package_name, 'prose', $_),
			    ),
			    {
				class => "b_sort_arrow $_",
				tag_if_empty => 1,
			    },
		        ),
			qw(ascend descend),
		    ),
		),
	    },
	),
    );
}

sub _xhtml {
    my($self, $html, $xhtml) = @_;
    return $self->unsafe_get('class') ? ($xhtml || sub {})->() : $html->();
}

1;
