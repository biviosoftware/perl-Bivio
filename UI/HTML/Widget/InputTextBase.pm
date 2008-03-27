# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::InputTextBase;
use strict;
use Bivio::Base 'HTMLWidget.InputBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_attributes {
    return [@{shift->SUPER::internal_attributes(@_)}, qw(size max_width)];
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('size');
    $self->unsafe_initialize_attr('max_width');
    return shift->SUPER::initialize(@_);
}

sub internal_input_base_render_attrs {
    my($self, $form, $field, $source, $buffer) = @_;
    shift->SUPER::internal_input_base_render_attrs(@_);
    my($req) = $source->get_request;
    my($size) = $self->render_simple_attr('size', $source);
    my($width) = $self->render_simple_attr('max_width', $source)
	|| $form->get_field_type($field)->get_width;
    $size += 2
	if $size == $width;
    $$buffer .= qq{ size="$size" maxlength="$width"};
    return;
}
1;
