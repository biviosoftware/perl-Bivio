# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::File;
use strict;
use Bivio::Base 'HTMLWidget.InputBase';


sub internal_attributes {
    return [@{shift->SUPER::internal_attributes(@_)}, qw(size)];
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr(class => 'b_input_file');
    $self->initialize_attr(TYPE => 'file');
    $self->initialize_attr('size');
    return shift->SUPER::initialize(@_);
}
sub internal_input_base_render_attrs {
    my($self, $form, $field, $source, $buffer) = @_;
    shift->SUPER::internal_input_base_render_attrs(@_);
    my($size) = $self->render_simple_attr('size', $source);
    $$buffer .= qq{ value="@{[$form->get_field_as_html($field)]}"}
	. qq{ size="$size"};
    return;
}

1;
