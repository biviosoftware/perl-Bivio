# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::DateTime;
use strict;
use Bivio::Base 'XMLWidget.Simple';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = __PACKAGE__->use('Type.DateTime');

sub render {
    my($self, $source, $buffer) = @_;
    $$buffer .= $_DT->to_xml(${$self->render_attr('value', $source)});
    return;
}

1;
