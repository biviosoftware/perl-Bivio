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

=item cells : array_ref (required,simple)

The widgets that are to be used to render the cells.  If the
widget is a scalar or array_ref, it identifies the field in the
list model to use.
A L<Bivio::UI::HTML::Widget::String|Bivio::UI::HTML::Widget::String>
instance will be created with the corresponding value.

=item table_cell_attrs : hash_ref [{string_font => 'table_cell'}]

Attributes to be applied to all table cells.  They will be overriden
by cell specific attributes.

=item cell_source : array_ref (required,simple)

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get the source to pass to the table cell widgets.

=item headings : array_ref (required,simple)

The widgets that are to be used for the column headings.
If the heading value is itself an array_ref, the first value is
the widget and the second value is the "sort field" to be passed
to the list model.  If the widget is a string, not a widget,
a L<Bivio::UI::HTML::Widget::String|Bivio::UI::HTML::Widget::String>
instance will be created.

=item table_heading_attrs: hash_ref [{string_font => 'table_heading'}]

Attributes to be applied to all table cells.  They will be overriden
by heading specific attributes.

=item table_heading_bgcolor : string [heading_bg]

The bgcolor of the heading row as defined by
L<Bivio::UI::Color|Bivio::UI::Color>.

=item table_pad : number [5]

The value to be passed to the C<CELLPADDING> attribute of the C<TABLE> tag.

=item table_stripe_bgcolor : string [table_stripe_bg]

The stripe color to use for even rows as defined by
L<Bivio::UI::Color|Bivio::UI::Color>.  If the color is
false, no striping will occur.

=back

=head1 CELL ATTRIBUTES

=over 4

=item table_column_align : string [LEFT]

How to align the value within the cell or heading.  The allowed (case
insensitive) values are defined in
L<Bivio::UI::Align|Bivio::UI::Align>.
The value affects the C<ALIGN> and C<VALIGN> attributes of the C<TD> tag.

The value applies separately to headings and cells.

=item table_column_expand : boolean [false]

If true, the column will be C<width="100%">.  Should only be
applied to headings.

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
    my($self, $source) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if exists($fields->{rows});
    my($p) = '<table border=0 cellspacing=0 cellpadding=';
    # We don't want to check parents
    my($expand) = $self->simple_unsafe_get('table_expand');
    $p .= $self->get_or_default('table_pad', $_DEFAULT_PAD);
    $p .= ' width="100%"' if $expand;
    $fields->{prefix} = $p . '>';
    $fields->{suffix} = '</table>';
    my($cell_attrs) = $self->get_or_default('table_cell_attrs',
	   {string_font => 'table_cell'});
    $fields->{cells} = [];
    my($c);
    foreach $c (@{$fields->{cells} = $self->simple_get('cells')}) {
	unless (UNIVERSAL::isa($c, 'Bivio::UI::HTML::Widget')) {
	    $c = Bivio::UI::HTML::Widget::String->new({
		value => ref($c) ? $c : [$c],
		# Make a copy
		%$cell_attrs,
	    });
	}
	else {
	    my($a);
	    foreach $a (keys(%$cell_attrs)) {
		$c->put($a, $cell_attrs->{$a}) unless $c->has_keys($a);
	    }
	}
    }
    my($h);
    my($heading_attrs) = $self->get_or_default('table_heading_attrs',
	    {string_font => 'table_heading'});
    foreach $h (@{$fields->{headings} = $self->simple_get('headings')}) {

	unless (UNIVERSAL::isa($c, 'Bivio::UI::HTML::Widget')) {
	    $c = Bivio::UI::HTML::Widget::String->new({
		value => ref($c) ? $c : [$c],
		# Make a copy
		%$heading_attrs,
	    });
	}
	else {
	    my($a);
	    foreach $a (keys(%$heading_attrs)) {
		$c->put($a, $heading_attrs->{$a}) unless $c->has_keys($a);
	    }
	}
    }

    my($heading_bgcolor) = $self->get_or_default('table_heading_bgcolor',
	    'heading_bg');
    my($c);
    foreach $c (@{$fields->{cells}}) {
	$num_cols = int(@$r) if $num_cols < int(@$r);
    }
    foreach $r (@$rows) {
	# search for "expand"
	my($expand_cols) = $num_cols - int(@$r) + 1;
	my(@cols) = @$r;
	$#$r = -1;
	my($c);
	foreach $c (@cols) {
	    my($p) = '<td';
	    if (ref($c)) {
		# parent not set, so won't pick up $self's $bgcolor, etc.
		my($align);
		($bgcolor, $expand, $align) = $c->unsafe_get(qw(
                        table_cell_bgcolor table_cell_expand table_cell_align));
		if ($expand) {
		    # First expanded cell gets all the rest of the columns.
		    # If the table is expanded itself, then set this cell's
		    # width to 100%.
		    $p .= " colspan=$expand_cols";
		    $p .= ' width="100%"' if $expand;
		    $expand_cols = 1;
		}
		$p .= qq! bgcolor="$bgcolor"! if $bgcolor;
		$p .= ' '.Bivio::UI::Align->from_any($align)
			->get_long_desc if $align;
#TODO: Table doesn't connect parent to child to avoid strange inheritance,
#      e.g. tables within tables.  Perhaps this is ok.  Need to try out.
#      If ok, then document above.
#		$c->put('parent', $self);
		$c->initialize($self, $source);
	    }
	    # Replace undef cells with something real.  Render
	    # text strings literally.
	    push(@$r, $p .'>', defined($c) ? $c : '', "</td>\n");
	}
    }
    $fields->{rows} = $rows;
    return;
}

=for html <a name="render"></a>

=head2 render(string_ref buffer)

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    $$buffer .= $fields->{prefix};
    my($r, $c);
#TODO: Optimize for is_constant
    foreach $r (@{$fields->{rows}}) {
	$$buffer .= "<tr>\n";
	foreach $c (@$r) {
	    ref($c) ? $c->render($source, $buffer) : ($$buffer .= $c);
	}
	$$buffer .= '</tr>';
    }
    $$buffer .= $fields->{suffix};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
