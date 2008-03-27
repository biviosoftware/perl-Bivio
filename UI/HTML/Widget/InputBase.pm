# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::InputBase;
use strict;
use Bivio::Base 'HTMLWidget.Tag';
use Bivio::UI::HTML::Format;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = __PACKAGE__->use('IO.Config');
my($_F) = __PACKAGE__->use('FacadeComponent.Font');
my($_VS) = __PACKAGE__->use('Bivio::UI::HTML::ViewShortcuts');

sub accepts_attribute {
    my($proto, $attr) = @_;
    return grep($_ eq $attr, @{$proto->internal_attributes}) ? 1 : 0;
}

sub control_on_render {
    my($self, $source, $buffer) = @_;
    $_C->if_version(
	6 => sub {
	    $self->SUPER::control_on_render($source, $buffer);
	    return;
	},
	sub {
	    my($p, $s) = $_F->format_html('input_field', $source->req);
	    $$buffer .= $p;
	    $self->SUPER::control_on_render($source, $buffer);
	    $$buffer .= $s;
	    return;
	}
    );
    $self->internal_input_base_post_render($source, $buffer);
    return;
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('field');
    $self->unsafe_initialize_attr('event_handler');
    $self->unsafe_initialize_attr('is_read_only');
    $self->initialize_attr(tag => 'input');
    $self->initialize_attr(value => '');
    $self->initialize_attr(tag_if_empty => 1);
    return shift->SUPER::initialize(@_);
}

sub internal_as_string {
    return shift->unsafe_get('field');
}

sub internal_attributes {
    return $_VS->vs_html_attrs_merge([qw(
	event_handler
	field
	form_model
	format
	is_read_only
    )]);
}

sub internal_input_base_post_render {
    my($self, $source, $buffer) = @_;
    if (my $h = $source->req->unsafe_get("$self")) {
	$h->render($source, $buffer);
    }
    return;
}

sub internal_input_base_render_attrs {
    my($self, $form, $field, $source, $buffer) = @_;
    my($req) = $source->get_request;
    $$buffer .= ' name="' . $form->get_field_name_for_html($field) . '"';
    if (my $h = $self->unsafe_resolve_attr('event_handler', $source)) {
	$req->put("$self" => $h);
	$$buffer .= ' ' . $h->get_html_field_attributes($field, $source);
    }
    else {
	# Just in case there was some transient state
	$req->delete("$self");
    }
    $$buffer .= ' disabled="1"'
	if $self->render_simple_attr('is_read_only', $source)
	|| !$form->is_field_editable($field);
    return;
}

sub internal_new_args {
    return shift->internal_compute_new_args(['field'], \@_);
}

sub internal_tag_render_attrs {
    my($self, $source, $buffer) = @_;
    shift->SUPER::internal_tag_render_attrs(@_);
    $self->internal_input_base_render_attrs(
	$self->resolve_ancestral_attr('form_model', $source->req),
	$self->render_simple_attr('field', $source),
	$source,
	$buffer,
    );
    return;
}

1;
