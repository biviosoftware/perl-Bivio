# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Select;
use strict;
$Bivio::UI::HTML::Widget::Select::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Select - select from a list of several items

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Select;
    Bivio::UI::HTML::Widget::Select->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Select::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Select> allows user to select from
a list of choices.

=head1 ATTRIBUTES

=over 4

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited)

Which form are we dealing with.

=item choices : Bivio::Type::Enum (required)

List of choices will be constructed from the Enum's values.

=item choices : Bivio::TypeValue (required)

List of choices will be constructed from a
L<Bivio::TypeValue|Bivio::TypeValue> whose type is a
L<Bivio::Type::EnumSet|Bivio::Type::EnumSet>.

=item choices : array_ref (required)

Widget value which returns
L<Bivio::Biz::ListModel|Bivio::Biz::ListModel>.

=item list_display_field : string (required if 'choices' is a list)

Name of the list field used for display.

=item list_id_field : string (required if 'choices' is a list)

Name of the list field used as the item id.

TODO: this attribute shouldn't exist - it should use the primary key
      fields of the list model.

=back

=cut

#=IMPORTS
use Bivio::Util;
use Bivio::Type::Enum;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Text

Creates a new Select widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.  In this case, prefix and suffix
field values.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{field} = $self->get('field');

    my($choices) = $self->get('choices');
    $fields->{list_source} = undef;
    if (UNIVERSAL::isa($choices, 'Bivio::Type::Enum')) {
	_load_items_from_enum($self, $choices);
    }
    elsif (!ref($choices)) {
	Carp::croak($choices, ': unknown choices type');
    }
    elsif (ref($choices) eq 'ARRAY') {
	# load it dynamically during render
	$fields->{list_source} = $choices;
    }
    elsif ($choices->isa('Bivio::TypeValue')
	   && $choices->get('type')->isa('Bivio::Type::EnumSet')) {
	_load_items_from_enum_set($self, $choices);
    }
    else {
	Carp::croak(ref($choices), ': unknown choices type');
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
    my($fields) = $self->{$_PACKAGE};
    my($form) = $source->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};
    unless ($fields->{initialized}) {
	my($type) = $fields->{type} = $form->get_field_type($field);
	$fields->{prefix} = '<select name='
		.$form->get_field_name_for_html($field)
		." size=1>\n";
	$fields->{initialized} = 1;
    }
    $$buffer .= $fields->{prefix};
    _load_items_from_list($self, $source) if $fields->{list_source};
    my($items) = $fields->{items};
    my($field_value) = $form->get($field);

    $field_value = '' unless defined($field_value);
    $field_value = $field_value->as_int if ref($field_value);

    for (my($i) = 0; $i < int(@$items); $i += 2) {
	my($v) = $items->[$i];
	$$buffer .= '<option value='.$v;
	$$buffer .= ' selected' if $field_value eq $v;
	$$buffer .= '>'.$items->[$i+1]."\n";
    }
    # No newline, don't know what follows.
    $$buffer .= '</select>';
    return;
}

#=PRIVATE METHODS

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

# _load_items_from_enum_list(Bivio::UI::HTML::Widget::Select self, array_ref list)
#
# Creates "items" from "list" of enum values.  Helper to _load_items_from_enum
# and _load_items_from_enum_set.
#
sub _load_items_from_enum_list {
    my($self, $list) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Sort
    my(@values) = sort {
	# Always put "0" (unknown) first.
	return -1 if $a->as_int == 0;
	return 1 if $b->as_int == 0;
	$a->get_name cmp $b->get_name
    } @$list;

    # id, display pairs
    my(@items);
    foreach my $item (@values) {
	push(@items, $item->as_int,
		Bivio::Util::escape_html($item->get_short_desc));
    }

    # Result
    $fields->{items} = \@items;
    return;
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

# _load_items_from_list(Bivio::UI::HTML::Widget::Select self, any source)
#
# Loads items from the list choices attribute. List values are
# dynamic so this is called during render.
#
sub _load_items_from_list {
    my($self, $source) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($list) = $source->get_widget_value(@{$fields->{list_source}});
    my($display_name) = $self->get('list_display_field');
    my($id_name) = $self->get('list_id_field');

    # id, display pairs
    my(@items);
    while($list->next_row) {
	push(@items, $list->get($id_name), $list->get($display_name));
    }
    $fields->{items} = \@items;

    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
