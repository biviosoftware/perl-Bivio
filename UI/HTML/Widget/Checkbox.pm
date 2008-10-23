# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Checkbox;
use strict;
use Bivio::Base 'HTMLWidget.InputBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VS) = __PACKAGE__->use('Bivio::UI::HTML::ViewShortcuts');
my($_C) = __PACKAGE__->use('IO.Config');

sub initialize {
    my($self) = @_;
    my($l) = $self->get_or_default('label', $_VS->vs_text(
	$self->ancestral_get('form_class')->simple_package_name,
	$self->get('field')));
    $self->put(label => $_C->if_version(
	6 => sub {
	    return $_VS->vs_new(
		'Tag', 'span', $_VS->vs_new(Prose => $l), 'checkbox_label');
	},
	sub {$_VS->vs_new(Join => ["\n", $_VS->vs_string($l, 'checkbox')])},
    )) unless Bivio::UI::Widget->is_blessed($l);
    $self->initialize_attr('label');
    $self->initialize_attr(class => 'checkbox');
    $self->initialize_attr(TYPE => 'checkbox');
    $self->unsafe_initialize_attr('auto_submit');
    return shift->SUPER::initialize(@_);
}

sub internal_attributes {
    return [@{shift->SUPER::internal_attributes(@_)}, qw(auto_submit label)];
}

sub internal_input_base_post_render {
    my($self, $source, $buffer) = @_;
    $self->unsafe_render_attr(label => $source, $buffer);
    shift->SUPER::internal_input_base_post_render(@_);
    return;
}

sub internal_input_base_render_attrs {
    my($self, $form, $field, $source, $buffer) = @_;
    shift->SUPER::internal_input_base_render_attrs(@_);
    $$buffer .= q{ checked="1"}
	if $form->get($field);
    $$buffer .= ' onclick="submit()"'
	if $self->render_simple_attr(auto_submit => $source);
    return;
}

1;
