# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::TextArea;
use strict;
use Bivio::Base 'HTMLWidget.ControlBase';

# C<Bivio::UI::HTML::Widget::TextArea> draws a C<INPUT> tag with
# attribute C<TYPE=TEXTAREA>.
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
# rows : int (required)
#
# The number of rows to show.
#
# cols : int (required)
#
# The number of character columns to show.
#
# readonly : boolean (optional) [0]
#
# Don't allow text-editing
#
# wrap : string (optional) [VIRTUAL]
#
# The text wrapping mode.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

sub control_on_render {
    my($self, $source, $buffer) = @_;
    $self->SUPER::control_on_render($source, $buffer);
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};

    # need first time initialization to get field name from form model
    unless ($fields->{initialized}) {
	my($type) = $fields->{type} = $form->get_field_type($field);
	my($attributes) = '';
	$self->unsafe_render_attr('edit_attributes', $source, \$attributes);
#TODO: need get_width or is it something else?
	$fields->{prefix} = '<textarea' . $attributes
	    . ($_VS->vs_html_attrs_render($self, $source) || '')
	    . join('', map(qq{ $_="$fields->{$_}"}, qw(rows cols wrap)));
        $fields->{prefix} .= ' readonly="readonly"'
	    if $fields->{readonly};
	$fields->{initialized} = 1;
    }
    my($p, $s) = Bivio::UI::Font->format_html('input_field', $req);
    $$buffer .= $p.$fields->{prefix}
	    . ' name="'
	    . $form->get_field_name_for_html($field)
	    . '">'
	    . $form->get_field_as_html($field)
	    . '</textarea>'
	    . $s;
    return;
}

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{model};
    $self->unsafe_initialize_attr('edit_attributes');
    $fields->{model} = $self->ancestral_get('form_model');
    ($fields->{field}, $fields->{rows}, $fields->{cols}) = $self->get(
	    'field', 'rows', 'cols');
    $fields->{wrap} = $self->get_or_default('wrap', 'virtual');
    $fields->{readonly} = $self->get_or_default('readonly', 0);
    return;
}

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] ||= {};
    return $self;
}

1;
