# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::After;
use strict;
use Bivio::Base 'Bivio::UI::Widget::ControlBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = shift;
    $self->initialize_attr('value');
    $self->initialize_attr('value_after');
    return $self->SUPER::initialize(@_);
}

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($before) = length($$buffer);
    $self->render_attr('value', $source, $buffer);
    $self->render_attr('value_after', $source, $buffer)
	if $before < length($$buffer);
    return;
}

sub internal_new_args {
    my(undef, $value, $value_after, $attributes) = @_;
    return '"value" attribute must be defined'
	unless defined($value);
    return '"value_after" attribute must be defined'
	unless defined($value_after);
    return {
	value => $value,
	value_after => $value_after,
	($attributes ? %$attributes : ()),
    };
}

1;
