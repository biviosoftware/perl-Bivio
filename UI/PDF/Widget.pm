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

=head1 METHODS

=cut

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

=for html <a name="get_pdf_y"></a>

=head2 get_pdf_y(Bivio::UI::PDF pdf, string y) : string

Returns the y location in PDF coordinates.

=cut

sub get_pdf_y {
    my($self, $pdf, $y) = @_;
    return $pdf->get_value('pageheight', 0) - $y;
}

=for html <a name="render"></a>

=head2 abstract render(any source, Bivio::UI::PDF pdf)

Draws value onto the PDF instance.

=cut

$_ = <<'}'; # for emacs
sub render {
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
