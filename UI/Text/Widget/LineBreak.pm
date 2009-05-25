# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Text::Widget::LineBreak;
use strict;
use Bivio::Base 'TextWidget.ControlBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub control_on_render {
    my($self, $source, $buffer) = @_;
    $$buffer .= "\n";
    return;
}

1;
