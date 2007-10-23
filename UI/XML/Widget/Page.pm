# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::Page;
use strict;
use Bivio::Base 'XMLWidget.SimplePage';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(content_type => 'text/html');
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    $$buffer .= qq{<?xml version="1.0" encoding="UTF-8"?>\n};
    return shift->SUPER::render(@_);
}

1;
