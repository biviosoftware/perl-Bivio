# Copyright (c) 2004 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::DollarCell;
use strict;
$Bivio::UI::HTML::Widget::DollarCell::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::DollarCell::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::DollarCell - formats with Dollar formatter

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::DollarCell;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::String>

=cut

use Bivio::UI::HTML::Widget::String;
@Bivio::UI::HTML::Widget::DollarCell::ISA = ('Bivio::UI::HTML::Widget::String');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::DollarCell> formats a cell with a dollar amount preceded by a dollar sign.  Sets the font to C<NUMBER_CELL>, alignment is C<RIGHT>.

=head1 ATTRIBUTES

=over 4

=item field : string (required)

Name of the field to render.

=item pad_left : int [1]

Number of spaces to pad to left (same as String's pad_left).

=back

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes String attributes.

=cut

sub initialize {
    my($self) = shift;
    return if $self->unsafe_get('value');
    $self->put(
	value => [$self->get('field'), 'HTMLFormat.Dollar'],
	column_align => $self->get_or_default('column_align', 'E'),
	cell_align => $self->get_or_default('cell_align', 'E'),
	pad_left => $self->get_or_default('pad_left', 1),
	column_nowrap => 1,
	cell_nowrap => 1,
    );
    $self->put(string_font => 'number_cell')
	unless defined($self->unsafe_get('string_font'));
    return $self->SUPER::initialize(@_);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2004 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
