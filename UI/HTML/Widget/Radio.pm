# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Radio;
use strict;
use Bivio::Base 'HTMLWidget.Checkbox';

my($_A) = b_use('IO.Alert');
my($_HTML) = b_use('Bivio.HTML');

sub initialize {
    my($self) = @_;

    if ($self->unsafe_get('value') && ! $self->unsafe_get('on_value')) {
        $_A->warn_deprecated('"value" deprecated, use "on_value" attribute');
        $self->put(on_value => $self->get('value'));
    }
    $self->initialize_attr('on_value');
    $self->initialize_attr(TYPE => 'radio');
    return shift->SUPER::initialize(@_);
}

sub internal_input_base_render_attrs {
    my($self, $form, $field, $source, $buffer) = @_;
    shift->SUPER::internal_input_base_render_attrs(@_);
    my($value) = _on_value($self, $source);
    $value = ref($value)
        ? $value->to_html($value)
         : $_HTML->escape($value);
    $$buffer .= qq{ value="$value"};
    return;
}

sub internal_is_checked {
    my($self, $form, $field, $source) = @_;
    return _on_value($self, $source)
        eq $form->get_field_type($field)->to_html($form->get($field))
            ? 1 : 0;
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(field on_value label)], \@_);
}

sub internal_want_multi_check_handler {
    return 0;
}

sub _on_value {
    my($self, $source) = @_;
    return UNIVERSAL::isa($self->get('on_value'), 'Bivio::Type::Enum')
        ? $self->get('on_value')->to_html($self->get('on_value'))
        : ${$self->render_attr('on_value', $source)};
}

1;
