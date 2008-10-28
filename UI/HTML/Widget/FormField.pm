# Copyright (c) 2001-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::FormField;
use strict;
use Bivio::Base 'Bivio::UI::Widget::Join';
use Bivio::UI::HTML::WidgetFactory;

# C<Bivio::UI::HTML::Widget::FormField>
#
# edit_attributes : hash_ref
#
# Attributes for the editable field widget.
#
# field : string (required)
#
# Full name of the form field. ex. 'LoginForm.RealmOwner.name'
#
# form_field_label : string [field]
#
# Value of the field label to be looked up in Facade.
#
# row_control : array_ref
#
# Widget value boolean which dynamically determines if the row should render.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VS) = __PACKAGE__->use('Bivio::UI::HTML::ViewShortcuts');

sub get_label_and_field {
    my($self) = @_;
    # Creates a label for the field, and returns the (label, field) pair.
    return ($_VS->vs_new('FormFieldLabel', {
	field => _get_field_name($self),
	label => $_VS->vs_new(After =>
	    $_VS->vs_new('Simple', $self->internal_get_label_value),
	    ':',
	),
	map({
	    my($v) = $self->unsafe_get($_);
	    $v ? ($_ => $v) : ();
	} qw(row_control row_class)),
    }), $self);
}

sub internal_get_label_value {
    my($self) = @_;
    # Returns the widget value which access the label.
    return $_VS->vs_new('Prose', $_VS->vs_text(
	$self->get_or_default('form_field_label', $self->get('field'))));
}

sub internal_new_args {
    my($proto, $field, $edit_attributes, $row_control) = @_;
    # Implements positional argument parsing for L<new|"new">.
    return {
	field => $field,
	($edit_attributes ? (edit_attributes => $edit_attributes) : ()),
	($row_control ? (row_control => $row_control) : ()),
    };
}

sub new {
    my($self) = shift->SUPER::new(@_);
    # Creates a new FormField widget. Call
    # L<get_label_and_field|"get_label_and_field"> to create a label for the
    # field automatically.
    # adds the error widget and the edit widget
    $self->put(values => [
	$_VS->vs_new('FormFieldError', {
	    field => _get_field_name($self),
	    label => $self->internal_get_label_value,
	}),
	Bivio::UI::HTML::WidgetFactory->create($self->get('field'),
		$self->get_or_default('edit_attributes', {}))
    ]);
    return $self;
}

sub _get_field_name {
    my($self) = @_;
    # Returns the shortened field name for a form field (doesn't include
    # the form model prefix).

    my($field_name) = $self->get('field');
    # remove the form model prefix
    $field_name =~ s/^.*?\.(.+)$/$1/;
    return $field_name;
}

1;
