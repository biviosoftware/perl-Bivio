# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::PercentCell;
use strict;
$Bivio::UI::HTML::Widget::PercentCell::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::PercentCell - formats a cell with a number

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::PercentCell;
    Bivio::UI::HTML::Widget::PercentCell->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::String>

=cut

use Bivio::UI::HTML::Widget::String;
@Bivio::UI::HTML::Widget::PercentCell::ISA = ('Bivio::UI::HTML::Widget::String');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::PercentCell> formats a cell with a number.
Sets the font to C<NUMBER_CELL>, alignment is C<RIGHT>.

=head1 ATTRIBUTES

=over 4

=item decimals : int [1]

Number of decimals to display.

=item field : string (required)

Name of the field to render.

=back

=cut

#=IMPORTS
use Bivio::UI::HTML::Format::Printf;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::PercentCell

Creates a new PercentCell widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::String::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes String attributes.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{initialized};
    my($field) = $self->get('field');
    my($d) = $self->get_or_default('decimals', 1);
    $self->put(
	    value => [$field, 'Bivio::UI::HTML::Format::Printf',
		'%.'.$d.'f%%'],
	    column_align => 'E',
	    pad_left => 1,
	    string_font => 'number_cell',
	    column_nowrap => 1,
	   );
    $fields->{initialized} = 1;
    $self->SUPER::initialize;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
