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

=item choices : string (required)

Name of the Bivio::Biz::ListModel returned from source->get_widget_value().
The values are looked up dynamically during render.

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
    if ($choices->isa('Bivio::Type::Enum')) {
	_load_items_from_enum($self, $choices);
	$fields->{list_source} = 0;
    }
    else {
	$fields->{list_source} = 1;
	# load it dynamically during render
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

# _load_items_from_enum(Bivio::Type::Enum enum)
#
# Loads items from the enum choices attribute. Enum values are static
# so this is called during initialize.
#
sub _load_items_from_enum {
    my($self, $enum) = @_;
    my($fields) = $self->{$_PACKAGE};

    my(@values) = sort {
	# Always put "0" (unknown) first.
	return -1 if $a->as_int == 0;
	return 1 if $b->as_int == 0;
	$a->get_name cmp $b->get_name
    } $enum->get_list;

    # id, display pairs
    my(@items);
    foreach my $item (@values) {
	push(@items, $item->as_int,
		Bivio::Util::escape_html($item->get_short_desc));
    }
    $fields->{items} = \@items;

    return;
}

# _load_items_from_list(any source)
#
# Loads items from the list choices attribute. List values are
# dynamic so this is called during render.
#
sub _load_items_from_list {
    my($self, $source) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($list) = $source->get_widget_value($self->get('choices'));
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
