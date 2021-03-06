# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::LineBreak;
use strict;
use Bivio::Base 'HTMLWidget.EmptyTag';


sub initialize {
    my($self) = @_;
    $self->put_unless_exists(tag => 'br');
    return shift->SUPER::initialize(@_);
}

1;
