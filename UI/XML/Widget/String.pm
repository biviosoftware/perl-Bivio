# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::String;
use strict;
use Bivio::Base 'XMLWidget.Simple';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_S) = __PACKAGE__->use('Type.String');

sub render {
    my($self, $source, $buffer) = @_;
    $$buffer .= $_S->to_xml(${$self->render_attr('value', $source)});
    return;
}

1;
