# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::t::CB;
use strict;
use base 'Bivio::UI::Widget::ControlBase';


sub control_on_render {
    my(undef, undef, $buffer) = @_;
    $$buffer .= 'CB';
    return;
}

1;
