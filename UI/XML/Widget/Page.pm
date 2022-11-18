# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::Page;
use strict;
use Bivio::Base 'XMLWidget.SimplePage';


sub initialize {
    my($self) = @_;
    $self->initialize_attr(content_type => 'text/xml');
    $self->initialize_attr(content_encoding => '');
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    $$buffer .= q{<?xml version="1.0" encoding="}
        . ($self->render_simple_attr('content_encoding', $source, $buffer)
           || 'ISO-8859-1')
        . qq{"?>\n};
    return shift->SUPER::render(@_);
}

1;
