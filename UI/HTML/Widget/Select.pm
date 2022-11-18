# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Select;
use strict;
use Bivio::Base 'HTMLWidget.MultipleChoice';

# C<Bivio::UI::HTML::Widget::Select> allows user to select from
# a list of choices.
#
# auto_submit : boolean [0]
#
# Should a click submit the form?
#
# disabled : boolean [0]
#
# Make the selection read-only
#
# size : int [1]
#
# How many rows should be visible

my(@_ATTRS) = qw(
    auto_submit
    choices
    disabled
    enum_sort
    event_handler
    field
    form_model
    list_display_field
    list_id_field
    show_unknown
    size
);
my($_F) = b_use('FacadeComponent.Font');

sub accepts_attribute {
    # (proto, string) : boolean
    # Does the widget accept this attribute?
    my(undef, $attr) = @_;
    return grep($_ eq $attr, @_ATTRS);
}

sub render {
    # (self, any, Text_ref) : undef
    # Render the input field.  First render is special, because we need
    # to extract the field's type and can only do that when we have a form.
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$self->ancestral_get('form_model')});
    my($field) = $self->get('field');
    my($p, $s) = $_F->format_html('input_field', $req);
    $$buffer .= $p
        . '<select name="'
        . $form->get_field_name_for_html($field)
        . '"';
    $$buffer .= ' '
        . $self->get('event_handler')->get_html_field_attributes($field, $source)
        if $self->unsafe_get('event_handler');
    my($class) = $self->render_simple_attr('class', $source);
    $$buffer .= (' class="' . $class . '"')
        if $class;
    if ($self->get_or_default('size', 1) ne '1') {
        $$buffer .= ' size="' . $self->get('size') . '"';
    }
    $$buffer .= ' disabled="disabled"'
        if $self->get_or_default('disabled', 0);
    $$buffer .= ' onchange="submit()"' if $self->unsafe_get('auto_submit');
    $$buffer .= ">\n";
    my($items) = $self->unsafe_get('choices')
        ? $self->internal_is_provider($self->get('choices'))
        ? _load_items_from_provider($self->get('choices'), $source)
        : $self->internal_load_items($req->get_widget_value(@{$self->get('choices')}))
        : $self->get('items');
    my($field_value) = $form->get_field_type($field)->to_html(
        $form->get($field));
    my($editable) = $form->is_field_editable($field)
#TODO: Why this?
        || $field_value eq '';
    my($ekl) = $self->render_simple_attr('unknown_label', $source);
    $self->map_by_two(sub {
        my($v, $k) = @_;
        $$buffer .= qq{<option value="$v"}
            . ($field_value eq $v ? ' selected="selected"' : '')
            . ">$k</option>\n"
            if $editable || $field_value eq $v;
        return;
    }, $ekl ? ['', $ekl, @$items] : $items);
    $$buffer .= '</select>'.$s;
    return shift->SUPER::render(@_);
}

sub _load_items_from_provider {
    my($choices, $source) = @_;
    return [map(
        ($_, $_),
        map($choices->to_html($_),
            @{$choices->provide_select_choices($source)}),
    )];
}

1;
