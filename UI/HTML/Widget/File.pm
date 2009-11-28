# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::File;
use strict;
use Bivio::Base 'Bivio::UI::Widget';

# C<Bivio::UI::HTML::Widget::File> is a file field for forms.
#
#
#
# field : string (required)
#
# Name of the form field.
#
# form_model : array_ref (required, inherited, get_request)
#
# Which form are we dealing with.
#
# size : int (required)
#
# How wide is the field represented.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub initialize {
    # (self) : undef
    # Initializes from configuration attributes.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{field} = $self->get('field');
    # Make sure required attribute defined
    $self->get('size');
    $fields->{is_first_render} = 1;
    return;
}

sub new {
    # (proto) : Widget.File
    # Creates a File widget.
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

sub render {
    # (self, any, string_ref) : undef
    # Draws the file field on the specified buffer.
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($form) = $source->get_request->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};

    # first render initialization
    if ($fields->{is_first_render}) {
	my($type) = $fields->{type} = $form->get_field_type($field);
	$fields->{prefix} = '<input type=file size="'.$self->get('size')
		.'" name="';
	$fields->{is_first_render} = 0;
    }
    $$buffer .= $fields->{prefix}.$form->get_field_name_for_html($field)
	    .'" value="'.$form->get_field_as_html($field)
	    .'" />';
    return;
}

1;
