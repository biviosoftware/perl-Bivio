# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Checkbox;
use strict;
use Bivio::Base 'HTMLWidget.InputBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_ID) = 0;
my($_V5) = b_use('IO.Config')->if_version(5);

sub initialize {
    my($self) = @_;
    my($id) = $self->unsafe_get('ID')
        ? $self->get('ID')
        : $self->initialize_attr(ID => $self->internal_want_multi_check_handler
            ? Join([
                'b_cb',
                [['->get_list_model'], '->get_cursor'],
            ])
            : ('b_cb' . ++$_ID),
        );
    $self->put(label => LABEL(_init_label($self))->put(FOR => $id));
    $self->initialize_attr('label');
    $self->initialize_attr(class => 'checkbox');
    $self->initialize_attr(TYPE => 'checkbox');
    $self->put(event_handler => MultiCheckHandler())
        if $self->internal_want_multi_check_handler;
    $self->unsafe_initialize_attr('auto_submit');
    return shift->SUPER::initialize(@_);
}

sub internal_attributes {
    return [@{shift->SUPER::internal_attributes(@_)}, qw(auto_submit label)];
}

sub internal_input_base_post_render {
    my($self, $source, $buffer) = @_;
    $self->unsafe_render_attr(label => $source, $buffer);
    return shift->SUPER::internal_input_base_post_render(@_);
}

sub internal_input_base_render_attrs {
    my($self, $form, $field, $source, $buffer) = @_;
    shift->SUPER::internal_input_base_render_attrs(@_);
    $$buffer .= q{ checked="checked"}
        if $self->internal_is_checked($form, $field, $source);
    $$buffer .= ' onclick="submit()"'
        if $self->render_simple_attr(auto_submit => $source);
    return;
}

sub internal_is_checked {
    my($self, $form, $field, $source) = @_;
    return $form->get($field);
}

sub internal_want_multi_check_handler {
    my($self) = @_;
    my($form) = $self->ancestral_get('form_class');
    return $form->isa('Bivio::Biz::ListFormModel')
        && $form->get_instance->get_field_info($self->get('field'), 'in_list')
            ? 1 : 0;
}

sub _init_label {
    my($self) = @_;
    my($l) = defined($self->unsafe_get('label'))
        ? $self->get('label')
        : vs_text($self->ancestral_get('form_class')->simple_package_name,
            $self->get('field'));
    if ($_V5) {
        return SPAN_checkbox_label(
            Bivio::UI::Widget->is_blesser_of($l)
                ? $l
                : Prose($l),
        );
    }
    return Bivio::UI::Widget->is_blesser_of($l)
        ? $l
        : Join(["\n", String($l, 'checkbox')]);
}

1;
