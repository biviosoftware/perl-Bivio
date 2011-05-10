# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Radio;
use strict;
use Bivio::Base 'Bivio::UI::Widget::ControlBase';

# C<Bivio::UI::HTML::Widget::Radio> is an input of type C<RADIO>.
# It always has a label, but the label may be a string or widget.
#
# auto_submit : boolean [0]
#
# Should the a click submit the form?
#
# control : any
#
# See L<Bivio::UI::Widget::ControlBase|Bivio::UI::Widget::ControlBase>.
#
# field : string (required)
#
# Name of the form field.
#
# form_model : array_ref (required, inherited, get_request)
#
# Which form are we dealing with.
#
# label : string (required)
#
# label : array_ref (required)
#
# label : Bivio::UI::Widget (required)
#
# String label to use.
#
# value : any (required)
#
# Scalar value of button or Bivio::Type::Enum.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = b_use('UI.Font');
my($_HTML) = b_use('Bivio.HTML');

sub control_on_render {
    # (self, any, string_ref) : undef
    # Draws the date field on the specified buffer.
    my($self, $source, $buffer) = @_;
    my($form) = $source->req
	->get_widget_value(@{$self->ancestral_get('form_model')});
    my($field) = $self->get('field');
    my($value) = UNIVERSAL::isa($self->get('value'), 'Bivio::Type::Enum')
        ? $self->get('value')
        : ${$self->render_attr('value', $source)};
    my($field_value) = $form->get_field_type($field)
	->to_html($form->get($field));
    $$buffer .= '<input name="'
	. $form->get_field_name_for_html($field)
	. '"'
	. ($value eq $field_value ? ' checked="checked"' : '')
	. ' type="radio" value="'
	. (ref($value)
	       ? $value->to_html($value)
	       : $_HTML->escape($value))
	 . "\""
	 . ($self->unsafe_get('auto_submit') ? ' onclick="submit()"' : '')
	 . " />&nbsp;";

    my($label) = $self->get('label');
    if (UNIVERSAL::isa($label, 'Bivio::UI::Widget')) {
	$label->render($source, $buffer);
    }
    else {
	my($p, $s) = $_F->format_html('radio', $source->req);
	$label = $source->get_widget_value(@$label)
	    if ref($label);
	$$buffer .= $p . $_HTML->escape($label) . $s;
    }
    return;
}

sub initialize {
    my($self) = @_;
    $self->get('label')->initialize_with_parent($self)
	if UNIVERSAL::isa($self->get('label'), 'Bivio::UI::Widget');
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $field, $value, $label, $attributes) = @_;
    return '"field" must be a defined scalar'
	unless defined($field) && !ref($field);
    return '"value" must be a scalar, array_ref, or Bivio::Type::Enum'
	unless defined($value)
	    && (!ref($value) || ref($value) eq 'ARRAY'
		|| UNIVERSAL::isa($value, 'Bivio::Type::Enum'));
    return {
	field => $field,
	value => $value,
	label => $label,
	($attributes ? %$attributes : ()),
    };
}

1;
