# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Grid;
use strict;
$Bivio::UI::HTML::Widget::Grid::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Grid - lays out widgets in a grid (html table)

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Grid;
    Bivio::UI::HTML::Widget::Grid->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Grid::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Grid> lays out widgets in an html table.
There are two types of attributes: table and cell.

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

=item border : number [0]

The value to be passed to the C<BORDER> attributes of the C<TABLE> tag.

=item expand : boolean [false]

If true, the table will C<WIDTH> will be C<100%>.

=item pad : number [0]

The value to be passed to the C<CELLPADDING> attribute of the C<TABLE> tag.

=item space : number [0]

The value to be passed to the C<CELLSPACING> attribute of the C<TABLE> tag.

=item values : array_ref (required)

An array_ref of rows of array_ref of columns (cells).  A cell may
be C<undef>.

=item width : int []

Set the width of the table explicitly.  I<expand> should be
used in most cases.

=back

=head1 CELL ATTRIBUTES

=over 4

=item cell_align : string []

How to align the value within the cell.  The allowed (case
insensitive) values are defined in
L<Bivio::UI::Align|Bivio::UI::Align>.
The value affects the C<ALIGN> and C<VALIGN> attributes of the C<TD> tag.

=item cell_bgcolor : string []

The value to be passed to the C<BGCOLOR> attribute of the C<TD> tag.
See L<Bivio::UI::Color|Bivio::UI::Color>.

=item cell_colspan : int [1]

The value passed to C<COLSPAN> attribute of the C<TD> tag.

=item cell_compact : boolean [false]

If true, the cell will be C<WIDTH=1%>.

=item cell_end : boolean [true]

If false, will not put cell end tag C<E<lt>/TD E<gt>>

=item cell_expand : boolean [false]

If true, the cell will consume any excess columns in its row.
Excess columns are not the same as C<undef> columns which are
blank place holders.

=item cell_height : int []

Sets the cell height explicitly.

=item cell_nowrap : boolean [false]

If true, the cell will not be wrapped.

=item cell_rowspan : int [1]

The value passed to C<ROWSPAN> attribute of the C<TD> tag.

=item cell_width : int []

Sets the cell width explicitly.

=back

=cut

#=IMPORTS
use Bivio::UI::Align;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES
    Bivio::UI::HTML::Widget::Form->new();

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Grid

Creates a new Grid widget.

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
    my($p) = '<table border='.$self->get_or_default('border', 0);
    # We don't want to check parents
    my($expand, $bg, $align, $width)
	    = $self->unsafe_get(qw(expand bgcolor align width));
    $p .= ' cellpadding='.$self->get_or_default('pad', 0);
    $p .= ' cellspacing='.$self->get_or_default('space', 0);
    $p .= ' width="100%"' if $expand;
    $p .= " width=\"$width\"" if $width;
    $p .= Bivio::UI::Align->as_html($align) if $align;
    $p .= Bivio::UI::Color->as_html_bg($bg) if $bg;
    $fields->{prefix} = $p . '>';
    $fields->{suffix} = '</table>';
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
	    my($p) = '<td';
	    my($end) = 1;
	    if (ref($c)) {
		# May set attributes on itself
		$c->put('parent', $self);
		$c->initialize($self, $source);
		my($align, $width, $height, $colspan, $rowspan);
		($bg, $expand, $align, $colspan, $rowspan, $width, $height)
			= $c->unsafe_get(qw(cell_bgcolor cell_expand
				cell_align cell_colspan cell_rowspan cell_width
				cell_height));
		if ($expand) {
		    # First expanded cell gets all the rest of the columns.
		    # If the grid is expanded itself, then set this cell's
		    # width to 100%.
		    $p .= " colspan=$expand_cols" if $expand_cols > 1;
		    $p .= ' width="100%"' if $expand;
		    $expand_cols = 1;
		}
#TODO: Need better crosschecking
		$p .= ' width="1%"' if $c->get_or_default('cell_compact', 0);
		$p .= Bivio::UI::Color->as_html_bg($bg) if $bg;
		$p .= Bivio::UI::Align->as_html($align) if $align;
		$p .= " rowspan=$rowspan" if $rowspan;
		$p .= " colspan=$colspan" if $colspan;
		$p .= ' nowrap' if $c->get_or_default('cell_nowrap', 0);
#TODO: Should be a number or percent?
		$p .= qq! width="$width"! if $width;
		$p .= qq! height="$height"! if $height;
		$end = $c->get_or_default('cell_end', 1);
	    }
	    elsif (!defined($c)) {
		# Replace undef cells with something real. 
		$c = '';
	    }
	    elsif ($c =~ /^\s+$/) {
		$p .= ' width="1%"';
		$c =~ s/\s/&nbsp;/g;
	    }
	    # Render scalars literally.
	    push(@$r, $p .'>', $c, $end ? "</td>\n" : '');
	}
    }
    $fields->{rows} = $rows;
    $fields->{is_constant} = 0;
    $fields->{is_first_render} = 1;
    return;
}


=for html <a name="is_constant"></a>

=head2 is_constant : boolean

Will return true if always renders exactly the same way.

=cut

sub is_constant {
    my($fields) = shift->{$_PACKAGE};
    Carp::croak('can only be called after first render')
		if $fields->{is_first_render};
    return $fields->{is_constant};
}

=for html <a name="render"></a>

=head2 render(string_ref buffer)

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    $$buffer .= $fields->{value}, return if $fields->{is_constant};

    my($start) = length($$buffer);
    $$buffer .= $fields->{prefix};
    my($r, $c);
    foreach $r (@{$fields->{rows}}) {
	$$buffer .= "<tr>\n";
	foreach $c (@$r) {
	    ref($c) ? $c->render($source, $buffer) : ($$buffer .= $c);
	}
	$$buffer .= '</tr>';
    }
    $$buffer .= $fields->{suffix};

    if ($fields->{is_first_render}) {
	$fields->{is_first_render} = 0;

	# Are the values constant?
	my($constant) = 1;
	foreach $r (@{$fields->{rows}}) {
	    foreach $c (@$r) {
		last unless $constant &&= !ref($c) || $c->is_constant;
	    }
	}
	# If values are constant, save off what we just rendered
	$fields->{value} = substr($$buffer, $start)
		if $fields->{is_constant} = $constant;
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
