# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::And;
use strict;
use base 'Bivio::UI::Widget::LogicalOpBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_render_end {
    my($self, $state, $last_value) = @_;
    $self->internal_render_true($state, $last_value)
	if $last_value;
    return; 
}

sub internal_render_operand {
    my(undef, $value) = @_;
    return $value ? 1 : 0;
}

1;
