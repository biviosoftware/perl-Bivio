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
@Bivio::UI::HTML::Widget::Table::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Table> renders a
L<Bivio::Biz::ListModel|Bivio::Biz::ListModel> in a table.

There are a few special heading and cell values:

=over 4

=item ' ' (spaces)

rendered as C<&nbsp;>

=item - (dash)

rendered as
L<Bivio::UI::HTML::Widget::LineCell|Bivio::UI::HTML::Widget::LineCell>
in C<summary_line> color and C<count> equal one.

=item = (equals)

rendered as
L<Bivio::UI::HTML::Widget::LineCell|Bivio::UI::HTML::Widget::LineCell>
in C<summary_line> color and C<count> equal two.

=back

=head1 TABLE ATTRIBUTES

=over 4

=item align : string [CENTER]

How to align the table.  The allowed (case
insensitive) values are defined in
L<Bivio::UI::Align|Bivio::UI::Align>.
The value affects the C<ALIGN> and C<VALIGN> attributes of the C<TD> tag.

=item bgcolor : string []

The value to be passed to the C<BGCOLOR> attribute of the C<TABLE> tag.
See L<Bivio::UI::Color|Bivio::UI::Color>.

=item cell_attrs : hash_ref [{string_font => 'table_cell'}]

Attributes to be applied to all table cells.  They will be overriden
by cell specific attributes.

=item cells : array_ref (required)

The widgets that are to be used to render the cells.  If the
widget is a scalar or array_ref, it identifies the field in the
list model to use.
A L<Bivio::UI::HTML::Widget::String|Bivio::UI::HTML::Widget::String>
instance will be created with the corresponding value.

=item end_tag : boolean [true]

If false, this widget won't render the C<&gt;/TABLE&lt;> tag.

=item empty_list_widget : Bivio::UI::HTML::Widget []

If set, the widget to display instead of the table when the
list_model is empty.

The I<source> will be the original source, not the list_model.

If not set, displays an empty table (with headers).

=item expand : boolean [false]

If true, the table will C<WIDTH> will be C<100%>.

=item heading_attrs: hash_ref [{string_font => 'table_heading', column_align => 'S'}]

Attributes to be applied to all table cells.  They will be overriden
by heading specific attributes.

=item heading_bgcolor : string []

The bgcolor of the heading row as defined by
L<Bivio::UI::Color|Bivio::UI::Color>.

=item headings : array_ref []

The widgets that are to be used for the column headings.
If the heading value is itself an array_ref, the first value is
the widget and the second value is the "sort field" to be passed
to the list model.  If the widget is a string, not a widget,
a L<Bivio::UI::HTML::Widget::String|Bivio::UI::HTML::Widget::String>
instance will be created.

=item leading_separator : boolean [true]

A separator will separate the cells from the heading.  The color will be
C<table_separator>.

=item pad : number [5]

The value to be passed to the C<CELLPADDING> attribute of the C<TABLE> tag.

=item source : array_ref []

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get the source to pass to the table heading and cell widgets.

=item start_tag : boolean [true]

If false, this widget won't render the C<&gt;TABLE&lt;>tag.

=item stripe_bgcolor : string [table_stripe_bg]

The stripe color to use for even rows as defined by
L<Bivio::UI::Color|Bivio::UI::Color>.  If the color is
false, no striping will occur.

=item trailing_separator : boolean [false]

A separator will separate the cells from the end.  The color will be
C<table_separator>.

=back

=head1 HEADING AND CELL ATTRIBUTES

=over 4

=item column_align : string [LEFT]

How to align the value within the cell or heading.  The allowed (case
insensitive) values are defined in
L<Bivio::UI::Align|Bivio::UI::Align>.
The value affects the C<ALIGN> and C<VALIGN> attributes of the C<TD> tag.

The value applies separately to headings and cells.

=item column_expand : boolean [false]

If true, the column will be C<width="100%">.  Should only be
applied to headings.

=item column_span : int [1]

The value for the C<COLSPAN> tag, which is not inserted if C<1>.

=item column_nowrap : boolean [false]

If true, the column won't wrap text.

=back

=cut

#=IMPORTS
use Bivio::UI::Align;
use Bivio::UI::Color;
use Bivio::UI::HTML::Widget::HorizontalRule;
use Bivio::UI::HTML::Widget::LineCell;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

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
    return if exists($fields->{headings});
    my($p) = '';
    if ($self->get_or_default('start_tag', 1)) {
	$p .= '<table border=0 cellspacing=0 cellpadding=';
	# We don't want to check parents
	$p .= $self->get_or_default('pad', 5);
	$p .= Bivio::UI::Align->as_html(
		$self->get_or_default('align', 'center'));
	$p .= ' width="100%"' if $self->get_or_default('expand', 0);
	my($bgcolor) = $self->get_or_default('bgcolor', 0);
	$p .= Bivio::UI::Color->as_html_bg($bgcolor) if $bgcolor;
	$p .= '>';
    }
    $fields->{prefix} = $p;
    $p = '';

    # Headings
    my($num_columns) = 0;
    if ($self->unsafe_get('headings')) {
	$p .= '<tr';
	my($bgcolor) = $self->get_or_default('heading_bgcolor', 0);
	$p .= Bivio::UI::Color->as_html_bg($bgcolor) if $bgcolor;
	my($headings) = [$p . ">\n"];
	my($heading_attrs) = $self->get_or_default('heading_attrs',
		{string_font => 'table_heading', column_align => 'S'});
	my($nc) = 0;
	foreach my $c (@{$self->get('headings')}) {
	    _init_cell($self, $headings, $heading_attrs, $c);
	    $nc++;
	}
        $fields->{headings} = $headings;
	$num_columns = $nc;
    }

    # Cells
    if ($self->unsafe_get('cells')) {
	# Stripe: finishes off previous row (which may be header)
	# First row is even (row = 0)
	$fields->{even_row} = "<tr>\n";
	$fields->{odd_row} = '<tr';
	my($bgcolor)
		= $self->get_or_default('stripe_bgcolor', 'table_stripe_bg');
	$fields->{odd_row} .= Bivio::UI::Color->as_html_bg($bgcolor)
		if $bgcolor;
	$fields->{odd_row} .= ">\n";

	my($cell_attrs) = $self->get_or_default('cell_attrs',
		{string_font => 'table_cell'});
	my($nc) = 0;
	my($cells) = [''];
	foreach my $c (@{$self->get('cells')}) {
	    _init_cell($self, $cells, $cell_attrs, $c);
	    $nc++;
	}
	$fields->{cells} = $cells;
	$num_columns = $nc if $nc > $num_columns;
    }
    $fields->{leading_separator} = $self->get_or_default('leading_separator',
	    1);
    $fields->{trailing_separator} = $self->get_or_default('trailing_separator',
	    0);
    if ($fields->{leading_separator} || $fields->{trailing_separator}) {
	$fields->{separator} = Bivio::UI::HTML::Widget::LineCell->new({
	    height => 1,
	    color => 'table_separator',
	});
	$fields->{separator_row} = "<tr><td colspan=$num_columns>";
	$fields->{separator}->put(parent => $self);
	$fields->{separator}->initialize;
    }
    Carp::croak('one of cells or headings must be defined')
		unless $fields->{headings} || $fields->{cells};
    $fields->{source} = $self->get('source');
    $fields->{end_tag} = $self->get_or_default('end_tag', 1);
    $fields->{empty_list_widget} = $self->get_or_default(
	    'empty_list_widget', undef);
    if ($fields->{empty_list_widget}) {
	$fields->{empty_list_widget}->put(parent => $self);
	$fields->{empty_list_widget}->initialize;
    }
    return;
}

=for html <a name="render"></a>

=head2 render(string_ref buffer)

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($list_model) = $source->get_widget_value(@{$fields->{source}});
    return $fields->{empty_list_widget}->render($source, $buffer)
	    if $fields->{empty_list_widget}
		    && $list_model->get_result_set_size == 0;
    $source = $list_model;

    $$buffer .= $fields->{prefix};
    # Headings
    if ($fields->{headings}) {
	foreach my $c (@{$fields->{headings}}) {
	    ref($c) ? $c->render($source, $buffer) : ($$buffer .= $c);
	}
	$$buffer .= "</tr>\n";
    }

    # Leading separator
    my($want_sep) = 1;
    if ($fields->{leading_separator}) {
	$$buffer .= $fields->{separator_row};
	$fields->{separator}->render($source, $buffer);
	$$buffer .= "</td></tr>\n";
	$want_sep = 0;
    }

    # Cells
    if ($fields->{cells}) {
	# Rows
	my($row) = 0;
	# Always start at beginning
	$source->reset_cursor;
	while ($source->next_row()) {
	    $$buffer .= $fields->{$row++ % 2 ? 'odd_row' : 'even_row'};
	    foreach my $c (@{$fields->{cells}}) {
		$$buffer .= $c, next unless ref($c);

		# Insert a "&nbsp;" if the widget doesn't render.  This
		# makes the table look nicer on certain browsers.
		my($start) = length($$buffer);
		$c->render($source, $buffer);
		$$buffer .= '&nbsp;' if length($$buffer) == $start;
	    }
	    $$buffer .= "</tr>\n";
	}
	$want_sep = 1 if $row > 0;
    }

    if ($fields->{trailing_separator} && $want_sep) {
	$$buffer .= $fields->{separator_row};
	$fields->{separator}->render($source, $buffer);
	$$buffer .= "</td></tr>\n";
    }

    # Always close off row, because headings is left unclosed
    $$buffer .= '</table>' if $fields->{end_tag};

    return;
}

#=PRIVATE METHODS

# _init_cell(Bivio::UI::HTML::Widget::Table self, array_ref cells, hash_ref attrs, any cell)
#
# Adds widget to cells, updating $cells->[$#$cells] with the attribute-
# based prefix.
#
sub _init_cell {
    my($self, $cells, $attrs, $cell) = @_;

    my($double, $single);
    unless (UNIVERSAL::isa($cell, 'Bivio::UI::HTML::Widget')) {
	if ($cell eq '-') {
	    $single = Bivio::UI::HTML::Widget::LineCell->new(
		    {color => 'summary_line', column_align => 'N', %$attrs})
		    unless $single;
	    $cell = $single;
	}
	elsif ($cell eq '=') {
	    $double = Bivio::UI::HTML::Widget::LineCell->new(
		    {color => 'summary_line', column_align => 'N',
			count => 2, %$attrs})
		    unless $double;
	    $cell = $double;
	}
	elsif ($cell =~ /^\s+$/) {
	    $cell =~ s/\s/&nbsp;/g;
	    $cell = Bivio::UI::HTML::Widget::Join->new({
		values => [$cell],
		%$attrs,
	    });
	}
	else {
	    $cell = Bivio::UI::HTML::Widget::String->new({
		value => $cell,
		%$attrs,
	    });
	}
    }
    else {
	my($a);
	foreach $a (keys(%$attrs)) {
	    $cell->put($a, $attrs->{$a}) unless $cell->has_keys($a);
	}
    }
    $cell->put(parent => $self);
    # May set attributes to be used by table
    $cell->initialize;
    my($prefix) = \$cells->[$#$cells];
    # Sanity check to make sure always can append
    die('prior cell is not a scalar') unless ref($prefix) eq 'SCALAR';
    $$prefix .= '<td';
    $$prefix .= ' width="100%"' if $cell->get_or_default('column_expand', 0);
    $$prefix .= ' nowrap' if $cell->get_or_default('column_nowrap', 0);
    my($span) = $cell->get_or_default('column_span', 1);
    $$prefix .= " colspan=$span" if $span != 1;
    my($bgcolor) = $cell->get_or_default('column_bgcolor', 0);
    $$prefix .= Bivio::UI::Color->as_html_bg($bgcolor) if $bgcolor;
    $$prefix .= Bivio::UI::Align->as_html(
	    $cell->get_or_default('column_align', 'LEFT'));
    $$prefix .= '>';
    push(@$cells, $cell, "</td>\n");
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
