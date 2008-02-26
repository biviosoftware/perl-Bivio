# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::Not;
use strict;
use Bivio::Base 'UI.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->initialize_attr('value');
    return;
}

sub internal_new_args {
    my(undef, $value, $attributes) = @_;
    return {
	value => $value,
	($attributes ? %$attributes : ()),
    };
}

sub render {
    my($self, $source, $buffer) = @_;
    $$buffer .= '1'
	unless $self->render_simple_attr('value', $source);
    return;
}

1;
