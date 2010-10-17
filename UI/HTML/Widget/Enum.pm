# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Enum;
use strict;
use Bivio::Base 'Bivio::UI::HTML::Widget::String';

# C<Bivio::UI::HTML::Widget::Enum> renders an enum as a string. By default this
# displays the result of 'get_short_desc'. This may be overridden by specifying
# a enum value to widget mapping in the optional 'display_values' attribute.
#
#
#
# field : string (required)
#
# Name of the enum field to render.
#
# display_values : hash_ref
#
# Map of enum values to display values. Overrides enum->get_short_desc.
# Values may be a string or Bivio::UI::Widget.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;


sub initialize {
    # (self) : undef
    # Initializes display_values and string attributes.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{initialized};

    # convert any display values to string widgets if necessary
    my($display_values) = $self->unsafe_get('display_values');
    if (defined($display_values)) {
	foreach my $field (keys(%$display_values)) {
	    my($value) = $display_values->{$field};
	    $value = Bivio::UI::HTML::Widget::String->new({
		value => $value,
	    }) unless ref($value);
	    $value->put(parent => $self);
	    $value->initialize;
	    $display_values->{$field} = $value;
	}
    }

    # default is to display the short description
    $self->put(value => [$self->get('field'), '->get_short_desc']);

    $fields->{initialized} = 1;
    $self->SUPER::initialize;
    return;
}

sub internal_new_args {
    # (proto, any, ...) : any
    # Implements positional argument parsing for L<new|"new">.
    my(undef, $field, $attributes) = @_;
    return {
	field => $field,
	($attributes ? %$attributes : ()),
    };
}

sub new {
    # (proto, hash_ref) : Widget.Enum
    # Creates a new Enum renderer.
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

sub render {
    # (self, any, string_ref) : undef
    # Draws the enum value onto the buffer.
    my($self, $source, $buffer) = @_;

    # check for an overridden display value
    my($value) = $source->get_widget_value($self->get('field'));
    return unless defined($value);
    my($display_values) = $self->unsafe_get('display_values');

    if (defined($display_values) && exists($display_values->{$value})) {
	$display_values->{$value}->render($source, $buffer);
    }
    else {
	$self->SUPER::render($source, $buffer);
    }
    return;
}

1;
