# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::PDF::Widget::Box;
use strict;
$Bivio::UI::PDF::Widget::Box::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::PDF::Widget::Box::VERSION;

=head1 NAME

Bivio::UI::PDF::Widget::Box - Renders text in a bounding box

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::PDF::Widget::Box;

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Widget>

=cut

use Bivio::UI::PDF::Widget;
@Bivio::UI::PDF::Widget::Box::ISA = ('Bivio::UI::PDF::Widget');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Widget::Box>

=head1 ATTRIBUTES

=over 4

=item align : string [left]

The justification of the text. May be left, right, center, justify or
fulljustify. Only left works correctly with multi string output.

=item height : numeric []

The height of the box in points. Defaults to the remaining page height.

=item location : array_ref (required)

The [x, y] location of the upper left corner of the bounding box. x and y
may be numeric coordinates, or the values 'textx' or 'texty' which uses
the current text location.

=item value : Bivio::UI::Widget (required)

The value to render in the box. Bivio::UI::PDF::Widget::String uses its
parent box to arrange itself.

=item width : numeric

The width of the bounding box. Defaults to the width of the container
from the x location of the bounding fox.

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::PDF::Widget::Box

Creates a new Box widget with I<attributes>.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
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
    $self->initialize_value('value', $self->get('value'));
    $self->put(align => 'left')
        unless $self->unsafe_get('align');
    return;
}

=for html <a name="render"></a>

=head2 render(any source, Bivio::UI::PDF pdf)

Renders the value.

=cut

sub render {
    my($self, $source, $pdf) = @_;
    my($fields) = $self->[$_IDI];

    # render time initialization
    my($size) = $self->get('parent')->ancestral_get('size');
    $fields->{location} = [_get_location($self, $pdf)];
    $self->put(width => $size->[0] - $fields->{location}->[0])
        unless $self->unsafe_get('width');
    $self->put(height => $size->[1] - $fields->{location}->[1])
        unless $self->unsafe_get('height');

    $fields->{has_text} = 0;
    $fields->{y_pos} = 0;

    $self->get('value')->render($source, $pdf);
    return;
}

=for html <a name="render_in_box"></a>

=head2 render_in_box(string text, Bivio::UI::PDF pdf)

Draws the value within the box.

=cut

sub render_in_box {
    my($self, $text, $pdf) = @_;
    my($fields) = $self->[$_IDI];
    # need to add spaces before newlines or the trailing newlines are lost
    $text =~ s/\n/ \n/g;
    my($x, $y) = @{$self->get_location_on_page(@{$fields->{location}})};
    $y = $self->get_pdf_y($pdf, $y);

    if ($fields->{has_text}) {
	$text = _render_trailing_text($self, $x, $text, $pdf);
	return if $text eq '';
    }

    my($height) = $self->get('height') - $fields->{y_pos};

    _trace('show boxed: ', $x, ' ', $y, ' ', $self->get('width'),
        ' ', $height) if $_TRACE;
    my($c) = $pdf->show_boxed($text, $x, $y - $self->get('height'),
	$self->get('width'), $height,
        $self->get('align'), '');
    Bivio::IO::Alert->warn("text clipped: ", $text) if $c;

    #$pdf->rect($x, $y - $self->get('height'),
    #    $self->get('width'), $height);
    #$pdf->stroke;

    if ($text =~ /\n$/) {
        $pdf->continue_text('');
    }

    $fields->{y_pos} = $y - $pdf->get_value('texty', 0);
    $fields->{has_text} = 1;
    return;
}

#=PRIVATE SUBROUTINES

# _get_location(Bivio::UI::PDF pdf) : (float, float)
#
# Returns the location of the widget. Translates textx and texty into
# actual coordinates.
#
sub _get_location {
    my($self, $pdf) = @_;
    my($fields) = $self->[$_IDI];
    my($x, $y) = @{$self->get('location')};
    my($parent_location) = $self->get('parent')->ancestral_get('location');

    if ($x eq 'textx') {
        $x = $pdf->get_value('textx', 0) - $parent_location->[0];
    }
    if ($y eq 'texty') {
        $y = $self->get_pdf_y($pdf,
            $pdf->get_value('texty', 0) + $parent_location->[1]);
    }
    return ($x, $y);
}

# _render_trailing_text(float x, string text, Bivio::UI::PDF pdf) : string
#
# Draws the trailing text. Returns any text which was not rendered.
#
sub _render_trailing_text {
    my($self, $x, $text, $pdf) = @_;
    my($textx) = $pdf->get_value('textx', 0);
    my($texty) = $pdf->get_value('texty', 0);
    my($width) = $x + $self->get('width') - $textx;
    my($line_size) = $pdf->get_value('leading', 0);

    my($c) = $pdf->show_boxed($text, $textx,
        $texty, $width, $line_size, $self->get('align'), '');

    return '' unless $c;

    $text = substr($text, length($text) - $c);
    $text =~ s/^\n//;
    return $text;
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
