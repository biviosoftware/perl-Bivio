# Copyright (c) 1999-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::DateField;
use strict;
use Bivio::Base 'HTMLWidget.InputTextBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Type.Date');

sub internal_render_tag_attr_value {
    my($self, $form, $field, $source, $buffer) = @_;
    my($v) = $_D->to_html(
       $form->get($field)
	   || ($self->render_simple_attr('allow_undef', $source) ? undef
	   : $_D->local_today),
    );
    $$buffer .= qq{ value="$v"};
    return;
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('field');
    $self->initialize_attr(size => $_D->get_width);
    $self->initialize_attr(max_width => $_D->get_width);
    $self->unsafe_initialize_attr('allow_undef');
    return shift->SUPER::initialize(@_);
}

sub internal_attributes {
    return [@{shift->SUPER::internal_attributes(@_)}, 'allow_undef'];
}

1;
