# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::Field;
use strict;
use Bivio::Base 'XMLWidget';


sub initialize {
    my($self) = @_;
    $self->put_unless_exists(to_method => 'to_xml');
    return shift->SUPER::initialize(@_);
}

1;
