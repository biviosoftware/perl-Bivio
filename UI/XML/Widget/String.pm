# Copyright (c) 2007-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::String;
use strict;
use Bivio::Base 'XMLWidget.Simple';

my($_S) = b_use('Type.String');

sub render {
    my($self, $source, $buffer) = @_;
    $$buffer .= $_S->to_xml($self->render_simple_attr(value => $source));
    return;
}

1;
