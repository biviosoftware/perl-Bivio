# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::AmountCell;
use strict;
use Bivio::Base 'HTMLWidget.String';

# C<Bivio::UI::HTML::Widget::AmountCell> formats a cell with a number.
# Sets the font to C<NUMBER_CELL>, alignment is C<RIGHT>.
#
#
#
# decimals : int [2]
#
# Number of decimals to display.
#
# field : string (required)
#
# Name of the field to render.
#
# pad_left : int [1]
#
# Number of spaces to pad to left (same as String's pad_left).
#
# want_parens : boolean [true]
#
# Should negative numbers be expressed with parens
#
# zero_as_blank : boolean [false]
#
# If true, renders the value 0 as ' '.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub initialize {
    my($self) = shift;
    # Initializes String attributes.
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

sub internal_new_args {
    my(undef, $field, $attributes) = @_;
    # Implements positional argument parsing for L<new|"new">.
    return {
        field => $field,
	($attributes ? %$attributes : ()),
    };
}

sub new {
    my($self) = shift->SUPER::new(@_);
    # Creates a new AmountCell widget.
    $self->[$_IDI] = {};
    return $self;
}

1;
