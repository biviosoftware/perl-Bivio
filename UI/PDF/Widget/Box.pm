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

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::PDF::Widget::Box::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Widget::Box>

=head1 ATTRIBUTES

=over 4

=item align : string [left]

The justification of the text. May be left, right, center, justify or
fulljustify. Only left works correctly with multi string output.

=item position : array_ref (required)

The [x, y] position of the upper left corner of the bounding box. x and y
may be numeric coordinates, or the values 'textx' or 'texty' which uses
the current text position.

=item value : Bivio::UI::Widget (required)

The value to render in the box. Bivio::UI::PDF::Widget::String uses its
parent box to arrange itself.

=item width : numeric

The width of the bounding box. Defaults to the width of the document
from the x position of the bounding fox.

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
    $self->initialize_value("value", $self->get('value'));
    my($page_size) = $self->ancestral_get('page_size');
    $self->put(width => $page_size->[0] - $self->get('position')->[0])
        unless $self->unsafe_get('width');
    $self->put(height => $page_size->[1] - $self->get('position')->[1])
        unless $self->unsafe_get('height');
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
    $fields->{has_text} = 0;
    $fields->{y_pos} = $self->get('height');

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

    my($x, $y) = @{$self->get('position')};
    $y = 0;

    if ($fields->{has_text}) {
	$text = _render_trailing_text($self, $x, $y, $text, $pdf);
	return if $text eq '';
    }

    _trace("show boxed: ", $x, ' ', $y, ' ', $self->get('width'),
        ' ', $fields->{y_pos}) if $_TRACE;
    my($c) = $pdf->show_boxed($text, $x,
	$y, $self->get('width'), $fields->{'y_pos'},
        $self->get('align'), "");

    $fields->{y_pos} = $pdf->get_value("texty", 0) - $y;
    $fields->{has_text} = 1;

    #$pdf->rect($x, $y, $self->get(qw(width height)));
    #$pdf->stroke;

    return;
}

#=PRIVATE SUBROUTINES

# _render_trailing_text(float x, float y, string text, Bivio::UI::PDF pdf) : string
#
# Draws the trailing text. Returns any text which was not rendered.
#
sub _render_trailing_text {
    my($self, $x, $y, $text, $pdf) = @_;
    my($textx) = $pdf->get_value("textx", 0);
    my($texty) = $pdf->get_value("texty", 0);
    my($width) = $x + $self->get('width') - $textx;
    my($line_size) = $pdf->get_value('leading', 0);

    my($c) = $pdf->show_boxed($text, $textx,
        $texty, $width, $line_size, $self->get('align'), "");

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
