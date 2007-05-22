# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::AmountCell;
use strict;
$Bivio::UI::HTML::Widget::AmountCell::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::AmountCell::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::AmountCell - formats a cell with a number

=head1 RELEASE SCOPE

bOP

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

=item pad_left : int [1]

Number of spaces to pad to left (same as String's pad_left).

=item want_parens : boolean [true]

Should negative numbers be expressed with parens

=item zero_as_blank : boolean [false]

If true, renders the value 0 as ' '.

=back

=cut

#=IMPORTS

#=VARIABLES

my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::AmountCell

Creates a new AmountCell widget.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes String attributes.

=cut

sub initialize {
    my($self) = shift;
    my($fields) = $self->[$_IDI];
    return if $fields->{initialized};
    $self->put(
	    value => [$self->get('field'), 'HTMLFormat.Amount',
		$self->get_or_default('decimals', 2),
		$self->get_or_default('want_parens', 1),
		$self->get_or_default('zero_as_blank', 0),
	    ],
	    column_align => $self->get_or_default('column_align', 'E'),
	    pad_left => $self->get_or_default('pad_left', 1),
	    column_nowrap => 1,
	   );
    $self->put(string_font => 'number_cell')
	    unless defined($self->unsafe_get('string_font'));
    $fields->{initialized} = 1;
    return $self->SUPER::initialize(@_);
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(string field) : hash_ref

=head2 static internal_new_args(string field, hash_ref attributes) : hash_ref

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $field, $attributes) = @_;
    return {
        field => $field,
	($attributes ? %$attributes : ()),
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
