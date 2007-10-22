# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::Field;
use strict;
use Bivio::Base 'Widget.ControlBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($field) = $self->render_simple_attr('field_name', $source);
    my($v) = $source->get($field);
    unless (defined($v)) {
	$self->control_off_render($source, $buffer);
	return;
    }
    my($to) = $self->render_simple_attr('to_method', $source);
    $$buffer .= $source->get_field_type($field)->$to($v);
    return;
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('field_name');
    $self->initialize_attr(to_method => 'to_string');
    return shift->SUPER::initialize(@_);
}


sub internal_as_string {
    return shift->unsafe_get('field_name');
}

sub internal_new_args {
    my(undef, $field_name, $attrs) = @_;
    return {
	field_name => $field_name,
	($attrs ? %$attrs : ()),
    };
}

1;
