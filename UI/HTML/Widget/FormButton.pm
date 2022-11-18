# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::FormButton;
use strict;
use Bivio::Base 'HTMLWidget.InputBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_HTML) = b_use('Bivio.HTML');

sub initialize {
    my($self) = @_;
    $self->initialize_attr(TYPE => 'submit');
    $self->put_unless_exists(label => vs_text_as_prose(
        $self->ancestral_get('form_class')->simple_package_name,
        $self->get('field'),
    ));
    $self->map_invoke(unsafe_initialize_attr => [qw(label attributes)]);
    return shift->SUPER::initialize(@_);
}

sub internal_input_base_render_attrs {
    my($self, $form, $field, $source, $buffer) = @_;
    shift->SUPER::internal_input_base_render_attrs(@_);
    my($v) = $_HTML->escape_attr_value(
        $self->render_simple_attr('label', $source));
    $$buffer .= qq{ value="$v"};
    my($attr) = $self->render_simple_attr('attributes', $source);
    $$buffer .= qq{ $attr}
        if $attr;
    return;
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(field ?class)], \@_);
}

1;
