# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::PDF::Widget::Grid;
use strict;
$Bivio::UI::PDF::Widget::Grid::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::PDF::Widget::Grid::VERSION;

=head1 NAME

Bivio::UI::PDF::Widget::Grid - Grid layout

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::PDF::Widget::Grid;

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Widget>

=cut

use Bivio::UI::PDF::Widget;
@Bivio::UI::PDF::Widget::Grid::ISA = ('Bivio::UI::PDF::Widget');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Widget::Grid>

=head1 ATTRIBUTES

=over 4

=item align : string []

How to align the grid.   The allowed (case insensitive) values are defined in
L<Bivio::UI::Align|Bivio::UI::Align>.

=item location : array_ref (required)

The [x, y] location of the upper left corner of the grid. x and y
may be numeric coordinates, or the values 'textx' or 'texty' which uses
the current text location.

=item pad : number [0]

The cell padding.

=item values : array_ref (required)

An array_ref of rows of array_ref of columns (cells).  A cell may
be C<undef>.  A cell may be a widget_value which returns a widget
or a string or it may be a widget or a string.

=back

=head1 CELL ATTRIBUTES

=over 4

=item cell_align : string [NE]

How to align the value within the cell.  The allowed (case
insensitive) values are defined in L<Bivio::UI::Align|Bivio::UI::Align>.

#=item cell_colspan : int [1]
#
#The number of columns for the cell.

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::UI::PDF::ViewShortcuts;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_IDI) = __PACKAGE__->instance_data_index;
my($_VS) = 'Bivio::UI::PDF::ViewShortcuts';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::PDF::Widget::Grid

Creates a new grid instance.

=cut

sub new {
    my($self) = Bivio::UI::PDF::Widget::new(@_);
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
    return if $fields->{box};
    $fields->{indirect} = $_VS->vs_new('Indirect', {value => 0});
    $fields->{box} = $self->initialize_value('box',
        $_VS->vs_new('Box', {value => $fields->{indirect},
            debug => $self->unsafe_get('debug')}));
    $fields->{pad} = $self->get_or_default('pad', 0);

    $fields->{cell_count} = 0;
    foreach my $row (@{$self->get('values')}) {
        my($cell_count) = 0;

        foreach my $cell (@$row) {
            $cell_count += $cell->get_or_default('cell_colspan', 1);
            $fields->{indirect}->initialize_value('cell', $cell);
        }
        if ($cell_count > $fields->{cell_count}) {
            $fields->{cell_count} = $cell_count;
        }
    }

    my($location) = $self->get('location');
    if ($location->[0] eq 'textx') {
        $fields->{align_textx} = 1;
        $location->[0] = 0;
    }
    if ($location->[1] eq 'texty') {
        $fields->{align_texty} = 1;
        $location->[1] = 0;
    }
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

=for html <a name="render"></a>

=head2 render(any source, Bivio::UI::PDF pdf)

Draws the text within the bounding box.

=cut

sub render {
    my($self, $source, $pdf) = @_;
    my($fields) = $self->[$_IDI];
    my($location) = $self->get('location');
    my($x, $y) = $self->get_location($pdf,
        $fields->{align_textx} ? 'textx' : $location->[0],
        $fields->{align_texty} ? 'texty' : $location->[1]);
    $location->[0] = $x;
    $location->[1] = $y;

    my($cell_width) = _compute_cell_width($self, $source, $pdf, $x);
    my($current_y) = 0;
    $self->put(size => [@{$self->get('parent')->ancestral_get('size')}]);
    $self->get('size')->[0] -= $x;
    $self->get('size')->[1] -= $y;

    foreach my $row (@{$self->get('values')}) {
        my($texty);
        my($current_x) = 0;

        for (my($i) = 0; $i < int(@$row); $i++) {
            my($cell) = $row->[$i];
            _trace("x, y, width = ", $current_x, ', ', $current_y, ', ',
                $cell_width->[$i]) if $_TRACE;
            $fields->{indirect}->put(value => $cell);
            $fields->{box}->put(
                location => [$current_x, $current_y],
                width => $cell_width->[$i],
                align => $cell->get_or_default('cell_align', 'left'),
               );
            $fields->{box}->render($source, $pdf);

            # advance to next cell position
            $current_x += $cell_width->[$i] + $fields->{pad};
            $texty ||= $pdf->get_value('texty', 0);
            if ($pdf->get_value('texty', 0) < $texty) {
                $texty = $pdf->get_value('texty', 0);
            }
        }
        $current_y = $self->get_texty($pdf, $texty) + $fields->{pad} - $y;
    }
    return;
}

#=PRIVATE SUBROUTINES

# _compute_cell_width(self, any source, Bivio::UI::PDF pdf, string x) : array_ref
#
# Computes and returns the width for the cells.
#
sub _compute_cell_width {
    my($self, $source, $pdf, $x) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($preferred_width) = [];
    my($width) = $self->get('parent')->ancestral_get('size')->[0]
         - ($fields->{pad} * $fields->{cell_count} - 1) - $x;
    my($default_cell_width) = $width / $fields->{cell_count};

    # compute the preferred width
    for (my $i = 0; $i < $fields->{cell_count}; $i++) {
        $self->set_render_mode($req, 0);

        foreach my $row (@{$self->get('values')}) {
            my($cell) = $row->[$i];
            next unless $cell;
            $cell->render($source, $pdf);
        }
        $preferred_width->[$i] = $self->get_max_text_width($req);
    }
    $self->set_render_mode($req, 1);

    # determine small cells and extra space
    my($cell_width) = [];
    my($extra) = 0;
    foreach my $width (@$preferred_width) {
        if ($width > $default_cell_width) {
            push(@$cell_width, $default_cell_width);
            next;
        }
        push(@$cell_width, $width);
        $extra += $default_cell_width - $width;
    }

    # incrementally add extra space to cells which want to be bigger
    my($done) = 0;
    while ($extra > 1 && ! $done) {
        $done = 1;
        for (my($i) = 0; $i < int(@$cell_width); $i++) {
            last unless $extra > 1;

            if ($preferred_width->[$i] > $cell_width->[$i]) {
                $cell_width->[$i]++;
                $extra--;
                $done = 0;
            }
        }
    }
    _trace($cell_width) if $_TRACE;
    return $cell_width;
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
