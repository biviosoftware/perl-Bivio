# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Select;
use strict;
$Bivio::UI::HTML::Widget::Select::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::Select::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::Select - select from a list of several items

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Select;
    Bivio::UI::HTML::Widget::Select->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::Select::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Select> allows user to select from
a list of choices.

=head1 ATTRIBUTES

=over 4

=item auto_submit : boolean [0]

Should a click submit the form?

=item choices : Bivio::Type::Enum (required)

List of choices will be constructed from the Enum's values.

=item choices : Bivio::TypeValue (required)

List of choices will be constructed from a
L<Bivio::TypeValue|Bivio::TypeValue> whose type is a
L<Bivio::Type::EnumSet|Bivio::Type::EnumSet> and value
is a string (set)
or type is L<Bivio::Type::EnumSet|Bivio::Type::Integer> and value
is an array_ref.

=item choices : array_ref (required, get_request)

Widget value which returns
L<Bivio::Biz::ListModel|Bivio::Biz::ListModel>
or a TypeValue which is an EnumSet.

=item disabled : boolean [0]

Make the selection read-only

=item enum_sort : string ['get_name']

The method on an enum which returns the value to compare in the sort.
If I<as_int>, the sort will be numeric.  Otherwise, it will be
string (cmp).

=item enum_sort : code_ref

Sort method to call.  Enums passed in I<left> and I<right> params,
just like L<Bivio::Type::compare|Bivio::Type/"compare">.  This is
a sub call, not a method call, so no method or self is passed.

=item event_handler : Bivio::UI::Widget []

If set, this widget will be initialized as a child and must
support a method C<get_html_field_attributes> which returns a
string to be inserted in this fields declaration.
I<event_handler> will be rendered before this field.

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=item list_display_field : string (required if 'choices' is a list)

Name of the list field used for display.

=item list_id_field : string (required if 'choices' is a list)

Name of the list field used as the item id.

TODO: this attribute shouldn't exist - it should use the primary key
      fields of the list model.

=item list_item_control : string []

The list field name which controls whether the current row should
be added to the list.

=item show_unknown : boolean [1]

Should the UNKNOWN type be displayed?

=item size : int [1]

How many rows should be visible

=back

=cut

#=IMPORTS
use Bivio::HTML;
use Bivio::IO::Trace;
use Bivio::Type::Enum;

#=VARIABLES

use vars ('$_TRACE');
Bivio::IO::Trace->register;
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

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Text

Creates a new Select widget.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="accepts_attribute"></a>

=head2 static accepts_attribute(string attr) : boolean

Does the widget accept this attribute?

=cut

sub accepts_attribute {
    my(undef, $attr) = @_;
    return grep($_ eq $attr, @_ATTRS);
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.  In this case, prefix and suffix
field values.

=cut

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

    return;
}

=for html <a name="render"></a>

=head2 render(any source, Text_ref buffer)

Render the input field.  First render is special, because we need
to extract the field's type and can only do that when we have a form.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};
    unless ($fields->{initialized}) {
	my($type) = $fields->{type} = $form->get_field_type($field);
	$fields->{prefix} = '<select ';
	$fields->{prefix} .= $fields->{handler}->get_html_field_attributes(
		$field, $source) if $fields->{handler};
	$fields->{prefix} .= ' name=';

	$fields->{initialized} = 1;
    }

    my($p, $s) = Bivio::UI::Font->format_html('input_field', $req);
    $$buffer .= $p.$fields->{prefix}.$form->get_field_name_for_html($field);
    $$buffer .= ' size='.$self->get_or_default('size', 1);
    $$buffer .= ' disabled' if $self->get_or_default('disabled', 0);
    $$buffer .= ' onchange="submit()"' if $fields->{auto_submit};
    $$buffer .= ">\n";

    my($items) = $fields->{choices}
	    ? _load_items($self, $req->get_widget_value(@{$fields->{choices}}))
	    : $fields->{items};
    my($field_value) = $form->get($field);

    $field_value = '' unless defined($field_value);
    $field_value = $field_value->as_int if ref($field_value);
    my($editable) = $form->is_field_editable($field)
	    || $field_value eq '';

    for (my($i) = 0; $i < int(@$items); $i += 2) {
	my($v) = $items->[$i];
	if ($editable || $field_value eq $v) {
	    $$buffer .= '<option value='.$v;
	    $$buffer .= ' selected' if $field_value eq $v;
	    $$buffer .= '>'.$items->[$i+1]."\n";
	}
    }
    # No newline, don't know what follows.
    $$buffer .= '</select>'.$s;

    # Handler is rendered after, because it probably needs to reference the
    # field.
    $fields->{handler}->render($source, $buffer) if $fields->{handler};

    return;
}

#=PRIVATE METHODS

# _enum_sort(self) : code_ref
#
# Returns the sort method.
#
sub _enum_sort {
    my($self) = @_;
    my($enum_sort) = $self->get_or_default('enum_sort', 'get_name');
    return $enum_sort if ref($enum_sort) eq 'CODE';
    Bivio::Die->die($enum_sort, ': enum_sort method not implemented by Enum')
		unless Bivio::Type::Enum->can($enum_sort);
    return \&_enum_sort_by_int if $enum_sort eq 'as_int';
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

# _enum_sort_by_int(string left, string right) : int
#
# Always puts "0" first.  Sorts numerically.
#
sub _enum_sort_by_int {
    my($left, $right) = @_;
    # Always put "0" (unknown) first.
    return -1 if $left->as_int == 0;
    return 1 if $right->as_int == 0;
    return $left->as_int <=> $right->as_int;
}

# _load_items(self, any choices) : array_ref
#
# Returns choices from the list of choices.
#
sub _load_items {
    my($self, $choices) = @_;
    # Most common dynamic case is first
    return _load_items_from_list($self, $choices)
	    if UNIVERSAL::isa($choices, 'Bivio::Biz::ListModel');
    return _load_items_from_enum($self, $choices)
	    if UNIVERSAL::isa($choices, 'Bivio::Type::Enum');
    if (UNIVERSAL::isa($choices, 'Bivio::TypeValue')) {
	my($t) = $choices->get('type');
	return _load_items_from_enum_set($self, $choices)
		if $t->isa('Bivio::Type::EnumSet');
	return _load_items_from_integer_array($self, $choices)
		if $t->isa('Bivio::Type::Integer')
			&& ref($choices->get('value')) eq 'ARRAY';
    }
    Bivio::Die->throw_die('DIE', {
	message => 'unknown choices type',
	program_error => 1,
	entity => $choices,
    });
    # DOES NOT RETURN
}

# _load_items_from_enum(Bivio::UI::HTML::Widget::Select self, Bivio::Type::Enum enum)
#
# Loads items from the enum choices attribute. Enum values are static
# so this is called during initialize.
#
#TODO: MERGE WITH RadioGrid
sub _load_items_from_enum {
    my($self, $enum) = @_;
    return _load_items_from_enum_list($self, [$enum->get_list]);
}

# _load_items_from_enum_list(Bivio::UI::HTML::Widget::Select self, array_ref list) : array_ref
#
# Creates "items" from "list" of enum values.  Helper to _load_items_from_enum
# and _load_items_from_enum_set.
#
sub _load_items_from_enum_list {
    my($self, $list) = @_;
    my($fields) = $self->[$_IDI];

    my(@values) = sort {
	&{$fields->{enum_sort}}($a, $b);
    } @$list;

    shift(@values) unless $self->get_or_default('show_unknown', 1);

    # id, display pairs
    my(@items);
    foreach my $item (@values) {
	push(@items, $item->as_int,
		Bivio::HTML->escape($item->get_short_desc));
    }

    # Result
    return \@items;
}

# _load_items_from_enum_set(Bivio::UI::HTML::Widget::Select self, Bivio::TypeValue choices)
#
# Loads items from the enum set choices attribute. EnumSet values are static
# so this is called during initialize.
#
sub _load_items_from_enum_set {
    my($self, $choices) = @_;
    my($type, $value) = $choices->get('type', 'value');
    my(@choices) = map {
	$type->is_set($value, $_) ? ($_) : ();
    } $type->get_enum_type->get_list;
    return _load_items_from_enum_list($self, \@choices);
}

# _load_items_from_enum_set(Bivio::UI::HTML::Widget::Select self, Bivio::TypeValue choices)
#
# Loads the items from an integer array_ref.
#
sub _load_items_from_integer_array {
    my($self, $choices) = @_;
    my($value) = $choices->get('value');
    return [map {($_, $_)} @$value];
}

# _load_items_from_list(Bivio::UI::HTML::Widget::Select self, Bivio::Biz::Listmodel list) : array_ref
#
# Loads items from the list choices attribute. List values are
# dynamic so this is called during render.
#
sub _load_items_from_list {
    my($self, $list) = @_;
    my($display_name) = $self->get('list_display_field');
    my($id_name) = $self->get('list_id_field');
    my($display_type) = $list->get_field_info($display_name, 'type');
    my($id_type) = $list->get_field_info($id_name, 'type');
    my($control) = $self->unsafe_get('list_item_control');

    # id, display pairs
    my(@items);
    $list->reset_cursor;
    while($list->next_row) {
	# skip rows unless the control value is set
	if ($control) {
	    next unless $list->get($control);
	}

	push(@items, $id_type->to_html($list->get($id_name)),
		$display_type->to_html($list->get($display_name)));
    }

    # reset the list cursor for the next guy
    $list->reset_cursor;

    return \@items;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
