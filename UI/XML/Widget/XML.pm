# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::XML;
use strict;
use Bivio::Base 'Widget.Simple';


sub render {
    my($self, $source, $buffer) = @_;
    my($b) = '';
    $self->SUPER::render($source, \$b);
    $$buffer .= Bivio::HTML->escape($b);
    return;
}

1;
