# Copyright (c) 2001-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::If;
use strict;
use Bivio::Base 'Widget.ControlBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return [qw(control control_on_value ?control_off_value)];
}

sub control_on_render {
    my($self, $source, $buffer) = @_;
    $self->render_attr('control_on_value', $source, $buffer);
    return;
}

sub initialize {
    my($self) = shift;
    $self->initialize_attr('control_on_value');
    return $self->SUPER::initialize(@_);
}

1;
