# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::Exists;
use strict;
use Bivio::Base 'UI.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->die('value', undef, 'attribute must be an array_ref')
	unless ref($self->initialize_attr('value')) eq 'ARRAY';
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
	if defined($source->unsafe_get_nested(@{$self->get('value')}));
    return;
}

1;
