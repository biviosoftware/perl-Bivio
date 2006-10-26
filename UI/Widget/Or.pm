# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::Or;
use strict;
use base 'Bivio::UI::Widget::LogicalOpBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_render_operand {
    my($self, $value, $state) = @_;
    return 1
	unless $value;
    $self->internal_render_true($state);
    return 0;
}

1;
