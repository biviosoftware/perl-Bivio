# Copyright (c) 2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::WithModel;
use strict;
use Bivio::Base 'Bivio::UI::Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_as_string {
    return shift->unsafe_get('model_class');
}

sub internal_new_args {
    my(undef, $model_class, $value, $attributes) = @_;
    return {
	model_class => $model_class,
	value => $value,
	($attributes ? %$attributes : ()),
    };
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('model_class');
    $self->initialize_attr('value');
    return;
}

sub render {
    my($self, $source, $buffer) = @_;
    $self->render_attr(
	'value',
	$source->get_request->get(
	    Bivio::Biz::Model->get_instance($self->render_simple_attr('model_class'))
	        ->package_name),
        $buffer,
    );
    return;
}

1;
