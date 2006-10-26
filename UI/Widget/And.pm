# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::And;
use strict;
use base 'Bivio::UI::Widget::LogicalOpBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_render_end {
    return shift->internal_render_true(@_);
}

sub internal_render_operand {
    my($self, $value) = @_;
    return $value ? 1 : 0;
}

1;
