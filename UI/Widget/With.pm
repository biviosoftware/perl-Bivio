# Copyright (c) 2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::With;
use strict;
use Bivio::Base 'UI.Widget';

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
    return;
}

sub render {
    my($self, $source, $buffer) = @_;
    $self->render_attr(
	'value',
	$self->resolve_attr('source', $source),
	$buffer,
    );
    return;
}

1;
