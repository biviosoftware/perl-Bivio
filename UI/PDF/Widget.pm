# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::PDF::Widget;
use strict;
$Bivio::UI::PDF::Widget::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::PDF::Widget::VERSION;

=head1 NAME

Bivio::UI::PDF::Widget - PDF widget base class

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::PDF::Widget;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::PDF::Widget::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Widget>

=cut

#=IMPORTS

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;
my($_TEXT_WIDTH_KEY) = __PACKAGE__ . '.text_width';
my($_RENDER_KEY) = __PACKAGE__ . '.render';
#my($_TEXT_SIZE_PAD) = 5;
my($_TEXT_SIZE_PAD) = 1;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::PDF::Widget

Creates a new PDF widget instance.

=cut

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_location"></a>

=head2 get_location(Bivio:UI::PDF pdf) : (number, number)

=head2 get_location(Bivio:UI::PDF pdf, string x, string y) : (number, number)

Returns the location of the widget. Translates textx and texty into
actual coordinates.

=cut

sub get_location {
    my($self, $pdf, $x, $y) = @_;
    my($parent_location) = $self->get('parent')->ancestral_get('location');

    unless (defined($x) && defined($y)) {
        ($x, $y) = @{$self->get('location')};
    }

    if ($x eq 'textx') {
        $x = $pdf->get_value('textx', 0) - $parent_location->[0];
    }
    if ($y eq 'texty') {
        $y = $self->get_pdf_y($pdf,
            $pdf->get_value('texty', 0) + $parent_location->[1]);
    }
    return ($x, $y);
}

=for html <a name="get_location_on_page"></a>

=head2 get_location_on_page() : array_ref

=head2 get_location_on_page(float x, float y) : array_ref

Returns the [x, y] coordinate of the widget's location on the page.

=cut

sub get_location_on_page {
    my($self, $x, $y) = @_;
    my($location) = defined($x) ? [$x, $y] : [@{$self->get('location')}];
    my($parent) = $self->unsafe_get('parent');

    while ($parent) {
        my($parent_location) = $parent->unsafe_get('location');
        if ($parent_location) {
            $location->[0] += $parent_location->[0];
            $location->[1] += $parent_location->[1];
        }
        $parent = $parent->unsafe_get('parent');
    }
    return $location;
}

=for html <a name="get_max_text_width"></a>

=head2 get_max_text_width(Bivio::Agent::Request) : string

Returns the max width of calls to save_text_width().

=cut

sub get_max_text_width {
    my($self, $req) = @_;
    return $req->get($_TEXT_WIDTH_KEY);
}

=for html <a name="get_pdf_y"></a>

=head2 get_pdf_y(Bivio::UI::PDF pdf, string y) : string

Returns the y location in PDF coordinates.

=cut

sub get_pdf_y {
    my($self, $pdf, $y) = @_;
    return $pdf->get_value('pageheight', 0) - $y;
}

=for html <a name="get_render_mode"></a>

=head2 get_render_mode(Bivio::Agent::Request req) : boolean

Returns the render mode.

=cut

sub get_render_mode {
    my($self, $req) = @_;
    return $req->get_or_default($_RENDER_KEY, 1);
}

=for html <a name="get_texty"></a>

=head2 get_texty(Bivio::UI::PDF pdf) : string

=head2 get_texty(Bivio::UI::PDF pdf, string texty) : string

Returns the y cordinate of the current text cursor. Converted from
PDF coordinates.

=cut

sub get_texty {
    my($self, $pdf, $texty) = @_;
    $texty = $pdf->get_value('texty', 0)
        unless defined($texty);
    my($parent_location) = $self->get('parent')->ancestral_get('location');
    return $self->get_pdf_y($pdf, $texty + $parent_location->[1]);
}

=for html <a name="render"></a>

=head2 abstract render(any source, Bivio::UI::PDF pdf)

Draws value onto the PDF instance.

=cut

$_ = <<'}'; # for emacs
sub render {
}

=for html <a name="save_text_width"></a>

=head2 save_text_width(Bivio::Agent::Request req, Bivio::UI::PDF pdf, string text)

Saves the text size on the request if it is greater that the current.

=cut

sub save_text_width {
    my($self, $req, $pdf, $text) = @_;

    my($size) = $pdf->stringwidth($text,
        $pdf->get_value('font', 0), $pdf->get_value('fontsize', 0))
        + $_TEXT_SIZE_PAD;
    if (defined($req->unsafe_get($_TEXT_WIDTH_KEY))) {
        return unless $req->get($_TEXT_WIDTH_KEY) < $size;
    }
    $req->put($_TEXT_WIDTH_KEY => $size);
    return;
}

=for html <a name="set_render_mode"></a>

=head2 set_render_mode(Bivio::Agent::Request req, boolean draw)

Sets the render mode. True draws on the PDF, false only computes text
size.

=cut

sub set_render_mode {
    my($self, $req, $draw) = @_;
    $req->put($_RENDER_KEY => $draw);
    $req->put($_TEXT_WIDTH_KEY => undef);
    return;
}

=for html <a name="unsafe_find_box"></a>

=head2 unsafe_find_box() : Bivio::UI::PDF::Widget::Box

Looks through the widget's parent hierarchy for the first box widget.
Returns undef if not found.

=cut

sub unsafe_find_box {
    my($self) = @_;
    my($widget) = $self;

    while ($widget) {
        return $widget
            if UNIVERSAL::isa($widget, 'Bivio::UI::PDF::Widget::Box');
        $widget = $widget->unsafe_get('parent');
    }
    return undef;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
