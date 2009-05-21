# Copyright (c) 1999-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::DateField;
use strict;
use Bivio::Base 'HTMLWidget.InputTextBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Type.Date');

sub internal_input_base_render_attrs {
    my($self, $form, $field, $source, $buffer) = @_;
    shift->SUPER::internal_input_base_render_attrs(@_);
    my($v) = $_D->to_html(
       $form->get($field)
	   || ($self->render_simple_attr('allow_undef', $source) ? undef
	   : $_D->local_today),
    );
    $$buffer .= qq{ value="$v"};
    return;
}

sub initialize {
    my($self, $source) = @_;
    my($f) = $self->initialize_attr('field', undef, $source);
    $self->initialize_attr(size => $_D->get_width, $source);
    $self->initialize_attr(max_width => $_D->get_width, $source);
    $self->initialize_attr(allow_undef => sub {
        return b_use('HTMLWidget.Form')
            ->form_model_for_initialize($self, $source)
            ->get_field_constraint($f)->eq_none;
    }, $source);
    return shift->SUPER::initialize(@_);
}

sub internal_attributes {
    return [@{shift->SUPER::internal_attributes(@_)}, 'allow_undef'];
}

1;
