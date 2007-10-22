# Copyright (c) 2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::With;
use strict;
use Bivio::Base 'Widget.ControlBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_as_string {
    return shift->unsafe_get('source');
}

sub internal_new_args {
    my(undef, $source, $value, $attributes) = @_;
    return {
	source => $source,
	value => $value,
	($attributes ? %$attributes : ()),
    };
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('source');
    $self->initialize_attr('value');
    return shift->SUPER::initialize(@_);
}

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($object) = $self->resolve_attr('source', $source);
    unless ($object->can('do_rows')) {
	$self->render_attr('value', $object, $buffer);
	return;
    }
    if ($object->can('get_result_set_size')
        && $object->get_result_set_size <= 0
    ) {
	$self->control_off_render($source, $buffer);
	return;
    }
    my($i) = 0;
    my($v) = $self->get('value');
    $object->do_rows(sub {
        $self->render_value('value' . $i++, $v, $object, $buffer);
	return 1;
    });
    return;
}

1;
