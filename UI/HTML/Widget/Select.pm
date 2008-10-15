# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Select;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::HTML;
use Bivio::Type::Enum;

# C<Bivio::UI::HTML::Widget::Select> allows user to select from
# a list of choices.
#
#
#
# auto_submit : boolean [0]
#
# Should a click submit the form?
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
# disabled : boolean [0]
#
# Make the selection read-only
#
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
# field : string (required)
#
# Name of the form field.
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
# list_item_control : string []
#
# The list field name which controls whether the current row should
# be added to the list.
#
# show_unknown : boolean [1]
#
# Should the UNKNOWN type be displayed?
#
# size : int [1]
#
# How many rows should be visible
#
# unknown_label : any []
#
# The label for the first element, whose value will always be the empty string
# (undef, null).  Will default I<show_unknown> to false, if defined (see code).

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my(@_ATTRS) = qw(
    auto_submit
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

sub accepts_attribute {
    # (proto, string) : boolean
    # Does the widget accept this attribute?
    my(undef, $attr) = @_;
    return grep($_ eq $attr, @_ATTRS);
}

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{field} = $self->get('field');
    $fields->{enum_sort} = _enum_sort($self);

    my($choices) = $self->get('choices');
    if (ref($choices) eq 'ARRAY') {
	# load it dynamically during render
	$fields->{choices} = $choices;
    }
    else {
	$fields->{choices} = undef;
	$fields->{items} = _load_items($self, $choices);
    }
    $fields->{auto_submit} = $self->get_or_default('auto_submit', 0);

    # Initialize handler, if any
    $fields->{handler} = $self->unsafe_get('event_handler');
    if ($fields->{handler}) {
	$fields->{handler}->put(parent => $self)->initialize;
    }

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

sub new {
    # (proto, hash_ref) : Widget.Text
    # Creates a new Select widget.
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

sub render {
    # (self, any, Text_ref) : undef
    # Render the input field.  First render is special, because we need
    # to extract the field's type and can only do that when we have a form.
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};
    my($p, $s) = Bivio::UI::Font->format_html('input_field', $req);
    $$buffer .= $p
	. '<select name="'
	. $form->get_field_name_for_html($field)
	. '"';
    $$buffer .= ' '
	. $fields->{handler}->get_html_field_attributes($field, $source)
	if $fields->{handler};
    $$buffer .= ' size="' .$self->get_or_default('size', 1) . '"';
    $$buffer .= ' disabled="1"'
	if $self->get_or_default('disabled', 0);
    $$buffer .= ' onchange="submit()"' if $fields->{auto_submit};
    $$buffer .= ">\n";

    my($items) = $fields->{choices}
	    ? _load_items($self, $req->get_widget_value(@{$fields->{choices}}))
	    : $fields->{items};
    my($field_value) = $form->get_field_type($field)->to_html(
	$form->get($field));
    my($editable) = $form->is_field_editable($field)
#TODO: Why this?
	|| $field_value eq '';
    my($ekl) = $self->render_simple_attr('unknown_label', $source);
    $self->map_by_two(sub {
        my($v, $k) = @_;
	$$buffer .= qq{<option value="$v"}
	    . ($field_value eq $v ? ' selected="1"' : '')
	    . " />$k\n"
	    if $editable || $field_value eq $v;
	return;
    }, $ekl ? ['', $ekl, @$items] : $items);
    $$buffer .= '</select>'.$s;
    $fields->{handler}->render($source, $buffer) if $fields->{handler};
    return;
}

sub _enum_sort {
    # (self) : code_ref
    # Returns the sort method.
    my($self) = @_;
    my($enum_sort) = $self->get_or_default('enum_sort', 'get_name');
    return $enum_sort
	if ref($enum_sort) eq 'CODE';
    Bivio::Die->die($enum_sort, ': enum_sort method not implemented by Enum')
	unless Bivio::Type::Enum->can($enum_sort);
    return \&_enum_sort_by_int
	if $enum_sort eq 'as_int';
    # Create a sub which will do the comparisons using $enum_sort method.
    return eval(<<"EOF") || die($@);
	sub {
            my(\$left, \$right) = \@_;
            # Always puts "0" first.
	    return -1 if \$left->as_int == 0;
	    return 1 if \$right->as_int == 0;
	    return \$left->$enum_sort cmp \$right->$enum_sort;
	}
EOF
}

sub _enum_sort_by_int {
    # (string, string) : int
    # Always puts "0" first.  Sorts numerically.
    my($left, $right) = @_;
    # Always put "0" (unknown) first.
    return -1 if $left->as_int == 0;
    return 1 if $right->as_int == 0;
    return $left->as_int <=> $right->as_int;
}

sub _load_items {
    # (self, any) : array_ref
    # Returns choices from the list of choices.
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
    Bivio::Die->throw_die('DIE', {
	message => 'unknown choices type',
	program_error => 1,
	entity => $choices,
    });
    # DOES NOT RETURN
}

sub _load_items_from_enum {
    # (Widget.Select, Type.Enum) : undef
    # Loads items from the enum choices attribute. Enum values are static
    # so this is called during initialize.
#TODO: MERGE WITH RadioGrid
    my($self, $enum) = @_;
    return _load_items_from_enum_list($self, [$enum->get_list]);
}

sub _load_items_from_enum_list {
    # (Widget.Select, array_ref) : array_ref
    # Creates "items" from "list" of enum values.  Helper to _load_items_from_enum
    # and _load_items_from_enum_set.
    my($self, $list) = @_;
    my($fields) = $self->[$_IDI];
    my(@values) = sort {
	$fields->{enum_sort}->($a, $b);
    } @$list;
    unless ($self->get_or_default(
	'show_unknown', $self->unsafe_get('unknown_label') ? 0 : 1)
    ) {
	shift(@values)
	    if @values && $values[0]->as_int == 0;
    }
    my($method) = $self->get_or_default('enum_display', 'get_short_desc');
    return [
	map(($_->as_int, Bivio::HTML->escape($_->$method)), @values),
    ];
}

sub _load_items_from_enum_set {
    # (Widget.Select, Bivio.TypeValue) : undef
    # Loads items from the enum set choices attribute. EnumSet values are static
    # so this is called during initialize.
    my($self, $choices) = @_;
    my($type, $value) = $choices->get('type', 'value');
    my(@choices) = map {
	$type->is_set($value, $_) ? ($_) : ();
    } $type->get_enum_type->get_list;
    return _load_items_from_enum_list($self, \@choices);
}

sub _load_items_from_integer_array {
    # (Widget.Select, Bivio.TypeValue) : undef
    # Loads the items from an integer array_ref.
    my($self, $choices) = @_;
    my($value) = $choices->get('value');
    return [map {($_, $_)} @$value];
}

sub _load_items_from_list {
    # (Widget.Select, Biz.Listmodel) : array_ref
    # Loads items from the list choices attribute. List values are
    # dynamic so this is called during render.
    my($self, $list) = @_;

    unless ($self->unsafe_get('list_id_field')) {
        my($keys) = $list->get_info('primary_key_names');
        Bivio::Die->die(
            "can't default list_id_field with multiple primary keys: ",
            $list) if int(@$keys) > 1;
        # default to first primary key field
        $self->put(list_id_field => $keys->[0]);
    }
    my($id_name) = $self->get('list_id_field');
    my($id_type) = $list->get_field_info($id_name, 'type');
    my($control) = $self->unsafe_get('list_item_control');
    return $list->map_rows(sub {
	$control && !$list->get($control) ? () : (
	    $id_type->to_html($list->get($id_name)),
	    ${$self->render_attr('list_display_field', $list)},
	);
    });
}

sub _load_items_from_string_array {
    # (Widget.Select, Bivio.TypeValue) : undef
    # Loads the items from an string array_ref.
    my($self, $choices) = @_;
    my($i) = $self->get_or_default('first_string_index', 1);
    return [map {($i++, Bivio::HTML->escape($_))} @{$choices->get('value')}];
}

1;
