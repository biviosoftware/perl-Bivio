# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::CDATA;
use strict;
use Bivio::Base 'Widget.Simple';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub render {
    my($self, $source, $buffer) = @_;
    $$buffer .= '<![CDATA[';
    $self->SUPER::render($source, $buffer);
    $$buffer .= ']]>';
    return;
}

1;
