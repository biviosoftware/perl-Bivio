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


=head1 TABLE ATTRIBUTES

=over 4

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

=item expand : boolean [false]

If true, the table will C<WIDTH> will be C<100%>.

=item heading_attrs: hash_ref [{string_font => 'table_heading'}]

Attributes to be applied to all table cells.  They will be overriden
by heading specific attributes.

=item heading_bgcolor : string [heading_bg]

The bgcolor of the heading row as defined by
L<Bivio::UI::Color|Bivio::UI::Color>.

=item no_end_tag : boolean [false]

If true, this widget won't render the end-table tag.

=item no_start_tag : boolean [false]

If true, this widget won't render the start-table tag.

=item headings : array_ref (required)

The widgets that are to be used for the column headings.
If the heading value is itself an array_ref, the first value is
the widget and the second value is the "sort field" to be passed
to the list model.  If the widget is a string, not a widget,
a L<Bivio::UI::HTML::Widget::String|Bivio::UI::HTML::Widget::String>
instance will be created.

=item pad : number [5]

The value to be passed to the C<CELLPADDING> attribute of the C<TABLE> tag.

=item source : array_ref (required)

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get the source to pass to the table heading and cell widgets.

=item stripe_bgcolor : string [table_stripe_bg]

The stripe color to use for even rows as defined by
L<Bivio::UI::Color|Bivio::UI::Color>.  If the color is
false, no striping will occur.

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

=item column_nowrap : boolean [false]

If true, the column won't wrap text.

=back

=cut

#=IMPORTS
use Bivio::UI::Align;
use Bivio::UI::Color;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_DEFAULT_STRIPE_COLOR) = 'TABLE_STRIPE_BG';
my($_DEFAULT_HEADING_COLOR) = 'HEADING_BG';
my($_DEFAULT_HEADING_ATTRS) = {};
my($_DEFAULT_CELL_ATTRS) = {};
my($_DEFAULT_PAD) = 5;

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
    if (! $self->get_or_default('no_start_tag', 0)) {
	$p .= '<table border=0 cellspacing=0 cellpadding=';
	# We don't want to check parents
	$p .= $self->get_or_default('pad', $_DEFAULT_PAD);
	$p .= ' width="100%"' if $self->get_or_default('expand', 0);
	my($bgcolor) = $self->get_or_default('bgcolor', 0);
	$p .= Bivio::UI::Color->as_html_bg($bgcolor) if $bgcolor;
	$p .= '>';
    }
    $p .= '<tr';
    my($bgcolor) = $self->get_or_default('heading_bgcolor', 'heading_bg');
    $p .= Bivio::UI::Color->as_html_bg($bgcolor) if $bgcolor;

    # Headings
    my($headings) = [$p . ">\n"];
    my($heading_attrs) = $self->get_or_default('heading_attrs',
	    {string_font => 'table_heading'});
    my($c);
    foreach $c (@{$self->get('headings')}) {
	_init_cell($self, $headings, $heading_attrs, $c);
    }
    $fields->{headings} = $headings;
    # Doesn't end in </tr>

    # Stripe: finishes off previous row (which may be header)
    # First row is even (row = 0)
    $fields->{even_row} = "</tr><tr>\n";
    $fields->{odd_row} = '</tr><tr';
    $bgcolor = $self->get_or_default('stripe_bgcolor', 'table_stripe_bg');
    $fields->{odd_row} .= Bivio::UI::Color->as_html_bg($bgcolor) if $bgcolor;
    $fields->{odd_row} .= ">\n";

    # Cells
    my($cell_attrs) = $self->get_or_default('cell_attrs',
	   {string_font => 'table_cell'});
    my($cells) = [''];
    foreach $c (@{$self->get('cells')}) {
	_init_cell($self, $cells, $cell_attrs, $c);
    }
    $fields->{cells} = $cells;
    $fields->{source} = $self->get('source');
    return;
}

=for html <a name="render"></a>

=head2 render(string_ref buffer)

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    print(STDERR "\n\n$source\n\n".$fields->{source}->[0]."\n\n"
	   .$source->get($fields->{source}->[0])."\n\n");
    $source = $source->get_widget_value(@{$fields->{source}});

    # Headings
    my($c);
    foreach $c (@{$fields->{headings}}) {
	ref($c) ? $c->render($source, $buffer) : ($$buffer .= $c);
    }

    # Rows
    my($row) = 0;
    while ($source->next_row()) {
	$$buffer .= $fields->{$row++ % 2 ? 'odd_row' : 'even_row'};
	foreach $c (@{$fields->{cells}}) {
	    ref($c) ? $c->render($source, $buffer) : ($$buffer .= $c);
	}
    }

    # Always close off row, because headings is left unclosed
    $$buffer .= "</tr>";
    $$buffer .= "</table>" if (! $self->get_or_default('no_end_tag', 0));

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

    unless (UNIVERSAL::isa($cell, 'Bivio::UI::HTML::Widget')) {
	$cell = Bivio::UI::HTML::Widget::String->new({
		value => $cell,
		# Make a copy
		%$attrs,
	});
    }
    else {
	my($a);
	foreach $a (keys(%$attrs)) {
	    $cell->put($a, $attrs->{$a}) unless $cell->has_keys($a);
	}
    }
    $cell->put(parent => $self);
    $cell->initialize;
    my($prefix) = \$cells->[$#$cells];
    die('last cell is not a scalar') unless ref($prefix) eq 'SCALAR';
    $$prefix .= '<td';
    $$prefix .= ' width="100%"' if $cell->get_or_default('column_expand', 0);
    $$prefix .= ' nowrap' if $cell->get_or_default('column_nowrap', 0);
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
