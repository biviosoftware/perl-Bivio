# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Text;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::HTML;
use Bivio::UI::HTML::Format;

# C<Bivio::UI::HTML::Widget::Text> draws a C<INPUT> tag with
# attribute C<TYPE=TEXT>.  If I<field> I<isa>
# L<Bivio::Type::Password|Bivio::Type::Password>,
# will render as a C<TYPE=PASSWORD>.
#
#
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
# form_model : array_ref (required, inherited, get_request)
#
# Which form are we dealing with.
#
# format : string []
#
# format : array_ref []
#
# Widget value which returns the formatter to format the field
# if it is not in error.  May return C<undef> iwc no formatting
# will done.
#
# Only in the first case will the formatter be dymically loaded.
# This is to prevent unnecessary transient state.
#
# The second form may be deprecated, so try to avoid it.
#
# is_read_only : boolean [!is_field_editable()]
#
# size : int (required)
#
# How wide is the field represented.  (maxlength comes from the
# field's type.)

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my(@_ATTRS) = qw(
    event_handler
    field
    form_model
    format
    size
    class
);

sub accepts_attribute {
    my(undef, $attr) = @_;
    # Does the widget accept this attribute?
    return grep($_ eq $attr, @_ATTRS);
}

sub initialize {
    my($self) = @_;
    # Initializes static information.  In this case, prefix and suffix
    # field values.
    my($fields) = $self->[$_IDI];
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    ($fields->{field}, $fields->{size}) = $self->get('field', 'size');
    $self->unsafe_initialize_attr('max_width');
    $self->initialize_attr(is_read_only => [
	'!',
	[['->get_request'],
	@{$fields->{model}}],
	'->is_field_editable',
	$fields->{field},
    ]);
    # Initialize handler, if any
    $fields->{handler} = $self->unsafe_get('event_handler');
    if ($fields->{handler}) {
	$fields->{handler}->put(parent => $self);
	$fields->{handler}->initialize;
    }

    $fields->{format} = $self->unsafe_get('format');
    $fields->{format}
	    = Bivio::UI::HTML::Format->get_instance($fields->{format})
		    if defined($fields->{format}) && !ref($fields->{format});
    return;
}

sub new {
    my($self) = shift->SUPER::new(@_);
    # Creates a new Text widget.
    $self->[$_IDI] = {};
    return $self;
}

sub render {
    my($self, $source, $buffer) = @_;
    # Render the input field.  First render is special, because we need
    # to extract the field's type and can only do that when we have a form.
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};
    unless ($fields->{initialized}) {
	my($type) = $fields->{type} = $form->get_field_type($field);

	# It works better to have one extra space if the size == max.
	my($s) = $fields->{size};
	my($w) = $self->render_simple_attr('max_width') || $type->get_width();
	$s++ if $s == $w;

	$fields->{prefix} = '<input type="'
		. ($type->is_password ? 'password' : 'text')
		. qq{" size="$s" maxlength="$w"};
	$fields->{initialized} = 1;
    }
    my($p, $s) = Bivio::UI::Font->format_html('input_field', $req);
    $$buffer .= $p
        . $fields->{prefix}
	. ' name="'
	. $form->get_field_name_for_html($field)
	. '"';
    if ($self->unsafe_get('class')) {
	$$buffer .= ' class="';
	$self->unsafe_render_attr('class', $source, $buffer);
	$$buffer .= '"';
    }
    $$buffer .= ' '.$fields->{handler}->get_html_field_attributes(
	$field, $source) if $fields->{handler};
    $$buffer .= ' disabled="1"'
	if $self->render_simple_attr('is_read_only', $source);
    my($v);
    if ($fields->{format} && !$form->get_field_error($field)) {
	my($f) = ref($fields->{format}) eq 'ARRAY'
		? $source->get_widget_value(@{$fields->{format}})
		: $fields->{format};
	if ($f) {
	    $v = $f->get_widget_value($form->get($field));
	    # Formatter must always return a defined value
	    $v = Bivio::HTML->escape($v)
		unless $f->result_is_html;
	}
    }
    $v = $form->get_field_as_html($field)
	unless defined($v);
    $$buffer .= qq{ value="$v" />$s};
    # Handler is rendered after, because it probably needs to reference the
    # field.
    $fields->{handler}->render($source, $buffer) if $fields->{handler};
    return;
}

1;
