# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::AmountCell;
use strict;
$Bivio::UI::HTML::Widget::AmountCell::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::AmountCell - formats a cell with a number

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::AmountCell;
    Bivio::UI::HTML::Widget::AmountCell->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::String>

=cut

use Bivio::UI::HTML::Widget::String;
@Bivio::UI::HTML::Widget::AmountCell::ISA = ('Bivio::UI::HTML::Widget::String');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::AmountCell> formats a cell with a number.
Sets the font to C<NUMBER_CELL>, alignment is C<RIGHT>.

=head1 ATTRIBUTES

=over 4

=item decimals : int [2]

Number of decimals to display.

=item field : string (required)

Name of the field to render.

=item zero_as_blank : boolean [false]

If true, renders the value 0 as ' '.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::AmountCell

Creates a new AmountCell widget.

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
    my($d) = $self->get_or_default('decimals', 2);
    my($zero_as_blank) = $self->get_or_default('zero_as_blank', 0);
    $self->put(
	    value => [$field, 'Bivio::UI::HTML::Format::Amount', $d, 1,
		   $zero_as_blank],
	    column_align => 'E',
	    string_font => 'number_cell',
	    pad_left => 1,
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
