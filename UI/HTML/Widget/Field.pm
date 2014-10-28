# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::Field;
use strict;
use Bivio::Base 'HTMLWidget';


sub initialize {
    my($self) = @_;
    $self->put_unless_exists(to_method => 'to_html');
    return shift->SUPER::initialize(@_);
}

1;
