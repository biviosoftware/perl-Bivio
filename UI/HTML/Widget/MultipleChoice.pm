# Copyright (c) 2011-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::MultipleChoice;
use strict;
use Bivio::Base 'UI.Widget';

my($_E) = b_use('Type.Enum');
my($_HTML) = b_use('Bivio.HTML');

#
# choices : Bivio::Type::Enum (required)
#
# List of choices will be constructed from the Enum's values.
#
# choices : Bivio::TypeValue (required)
#
# List of choices will be constructed from a
# L<Bivio::TypeValue|Bivio::TypeValue> whose type is a
# L<Bivio::Type::EnumSet|Bivio::Type::EnumSet> and value
# is a string (set)
# or type is L<Bivio::Type::Integer|Bivio::Type::Integer> and value
# is an array_ref.
# or type is L<Bivio::Type::String|Bivio::Type::String> and value
# is an array_ref of strings (value is 1..n)
#
# choices : array_ref (required, get_request)
#
# Widget value which returns
# L<Bivio::Biz::ListModel|Bivio::Biz::ListModel>
# or a TypeValue which is an EnumSet.
#
# field : string (required)
#
# Name of the form field.
#
# form_model : array_ref (required, inherited, get_request)
#
# Which form are we dealing with.
#
# show_unknown : boolean [1]
#
# Should the UNKNOWN type be displayed?
# enum_sort : string ['get_name']
#
# The method on an enum which returns the value to compare in the sort.
# If I<as_int>, the sort will be numeric.  Otherwise, it will be
# string (cmp).
#
# enum_sort : code_ref
#
# Sort method to call.  Enums passed in I<left> and I<right> params,
# just like L<Bivio::Type::compare|Bivio::Type/"compare">.  This is
# a sub call, not a method call, so no method or self is passed.
#
# enum_display : string ['get_short_desc']
#
# Display method for enums.
#
# event_handler : Bivio::UI::Widget []
#
# If set, this widget will be initialized as a child and must
# support a method C<get_html_field_attributes> which returns a
# string to be inserted in this fields declaration.
# I<event_handler> will be rendered before this field.
#
# first_string_index : int [1]
#
# Index of first string item.
#
# form_model : array_ref (required, inherited, get_request)
#
# Which form are we dealing with.
#
# list_display_field : string (required if 'choices' is a list)
#
# Name of the list field used for display.
#
# list_display_field : array_ref (required if 'choices' is a list)
#
# Widget value for the list display.
#
# list_display_field : Bivio::UI::Widget (required if 'choices' is a list)
#
# Widget for the list display.
#
# list_id_field : string
#
# Name of the list field used as the item id.
# Defaults to the list primary key.
#
#
# show_unknown : boolean [1]
#
# Should the UNKNOWN type be displayed?
#
# unknown_label : any []
#
# The label for the first element, whose value will always be the empty string
# (undef, null).  Will default I<show_unknown> to false, if defined (see code).

sub initialize {
    my($self) = @_;
    b_die('unsupported attribute')
        if $self->unsafe_get('list_item_control');
    $self->put(enum_sort => _enum_sort($self));
    my($choices) = $self->get('choices');
    if (ref($choices) eq 'ARRAY' || $self->internal_is_provider($choices)) {
        # load it dynamically during render
    }
    else {
        $self->delete('choices');
        $self->put(items => $self->internal_load_items($choices));
    }
    $self->get('event_handler')->initialize_with_parent($self)
        if $self->unsafe_get('event_handler');
    my($list_display) = $self->unsafe_get('list_display_field');
    if ($list_display) {
        unless (ref($list_display)) {
            $self->put(list_display_field =>
                ['->get_as', $list_display, 'to_html']);
        }
        $self->initialize_attr('list_display_field');
    }
    $self->unsafe_initialize_attr('unknown_label');
    return;
}

sub internal_is_provider {
    my($self, $choices) = @_;
    return $choices
        && UNIVERSAL::isa($choices, 'Bivio::UNIVERSAL')
        && $choices->can('provide_select_choices');
}

sub internal_load_items {
    my($self, $choices) = @_;
    $choices = $self->use($choices)
        unless ref($choices);
    return _load_items_from_list($self, $choices)
        if UNIVERSAL::isa($choices, 'Bivio::Biz::ListModel');
    return _load_items_from_enum($self, $choices)
        if UNIVERSAL::isa($choices, 'Bivio::Type::Enum');
    if (UNIVERSAL::isa($choices, 'Bivio::TypeValue')) {
         my($t) = $choices->get('type');
        return _load_items_from_enum_set($self, $choices)
            if $t->isa('Bivio::Type::EnumSet');
        if (ref($choices->get('value')) eq 'ARRAY') {
            return _load_items_from_enum_list($self, $choices->get('value'))
                if $t->isa('Bivio::Type::Enum');
            return _load_items_from_integer_array($self, $choices)
                if $t->isa('Bivio::Type::Integer');
            return _load_items_from_string_array($self, $choices)
                if $t->isa('Bivio::Type::String');
        }
    }
    b_die('unknown choices type: ', $choices)
    # DOES NOT RETURN
}

sub render {
    my($self, $source, $buffer) = @_;
    $self->get('event_handler')->render($source, $buffer)
        if $self->unsafe_get('event_handler');
    return;
}

sub _enum_sort {
    my($self) = @_;
    my($enum_sort) = $self->get_or_default('enum_sort', 'get_name');
    return $enum_sort
        if ref($enum_sort) eq 'CODE';
#TODO: This is type dependent
    b_die($enum_sort, ': enum_sort method not implemented by Enum')
        unless $_E->can($enum_sort);
    return Bivio::Die->eval_or_die(<<"EOF");
        sub {
            my(\$left, \$right) = \@_;
            my(\$li, \$ri) = map(\$_->as_int, \@_);
            return 0
                if \$li == \$ri;
            return -1
                if \$li == 0;
            return 1
                if \$ri == 0;
            return \$left->$enum_sort <=> \$right->$enum_sort
                if '$enum_sort' =~ /_int\$/;
            return \$left->$enum_sort cmp \$right->$enum_sort;
        }
EOF
}

sub _load_items_from_enum {
    my($self, $enum) = @_;
    return _load_items_from_enum_list($self, [$enum->get_list]);
}

sub _load_items_from_enum_list {
    my($self, $list) = @_;
    my($sort) = $self->get('enum_sort');
    my($values) = [sort({$sort->($a, $b)} @$list)];
    shift(@$values)
        if !$self->get_or_default(
            'show_unknown', $self->unsafe_get('unknown_label') ? 0 : 1
        )
        && @$values
        && $values->[0]->as_int == 0;
    my($method) = $self->get_or_default('enum_display', 'get_short_desc');
    return [
        map(($_->as_int, $_HTML->escape($_->$method)), @$values),
    ];
}

sub _load_items_from_enum_set {
    my($self, $choices) = @_;
    my($type, $value) = $choices->get('type', 'value');
    return _load_items_from_enum_list(
        $self,
        [grep(
            $type->is_set($value, $_),
            $type->get_enum_type->get_list,
        )],
    );
}

sub _load_items_from_integer_array {
    my($self, $choices) = @_;
    return [map {($_, $_)} @{$choices->get('value')}];
}

sub _load_items_from_list {
    my($self, $list) = @_;
    unless ($self->unsafe_get('list_id_field')) {
        my($keys) = $list->get_info('primary_key_names');
        b_die(
            $list,
            ': ',
            @$keys ? 'too many primary key fields' : ': no primary keys?',
        ) unless @$keys == 1;
        $self->put(list_id_field => $keys->[0]);
    }
    my($id_name) = $self->get('list_id_field');
    my($id_type) = $list->get_field_info($id_name, 'type');
    return $list->map_rows(
        sub {
            my($i) = $list->get($id_name);
            my($d) = ${$self->render_attr('list_display_field', $list)};
            return (
                $id_type->to_html($i),
                # See get_as above
                $d,
            );
        },
    );
}

sub _load_items_from_string_array {
    my($self, $choices) = @_;
    my($i) = $self->get_or_default('first_string_index', 1);
    return [map(($i++, $_HTML->escape($_)), @{$choices->get('value')})];
}

1;
