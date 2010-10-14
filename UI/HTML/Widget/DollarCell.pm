# Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::DollarCell;
use strict;
use Bivio::Base 'Bivio::UI::HTML::Widget::String';

# C<Bivio::UI::HTML::Widget::DollarCell> formats a cell with a dollar amount preceded by a dollar sign.  Sets the font to C<NUMBER_CELL>, alignment is C<RIGHT>.
#
#
#
# field : string (required)
#
# Name of the field to render.
#
# pad_left : int [1]
#
# Number of spaces to pad to left (same as String's pad_left).

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    # (self) : undef
    # Initializes String attributes.
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

sub internal_new_args {
    # (self, any, ...) : hash_ref
    # Converts positional to hash notation.
    my(undef, $field, $attributes) = @_;
    return '"field" attribute must be defined'
	unless defined($field);
    return {
	field => $field,
	($attributes ? %$attributes : ()),
    };
}

1;
