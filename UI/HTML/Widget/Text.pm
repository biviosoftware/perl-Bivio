# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Text;
use strict;
use Bivio::Base 'HTMLWidget.InputTextBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->unsafe_initialize_attr('format');
    return shift->SUPER::initialize(@_);
}

sub internal_attributes {
    return [@{shift->SUPER::internal_attributes(@_)}, 'format'];
}

sub internal_input_base_render_attrs {
    my($self, $form, $field, $source, $buffer) = @_;
    shift->SUPER::internal_input_base_render_attrs(@_);
    my($v);
    if (!$form->get_field_error($field)
        and my $f = $self->unsafe_resolve_attr('format', $source)
    ) {
	$f = Bivio::UI::HTML::Format->get_instance($f)
	    unless ref($f);
	$v = $f->get_widget_value($form->get($field));
	$v = Bivio::HTML->escape($v)
	    unless $f->result_is_html;
    }
    $v = $form->get_field_as_html($field)
	unless defined($v);
    $$buffer .= qq{ value="$v"};
    return;
}

1;
