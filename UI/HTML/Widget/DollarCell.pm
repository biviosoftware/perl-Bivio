# Copyright (c) 2004-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::DollarCell;
use strict;
use Bivio::Base 'HTMLWidget.AmountCell';


sub initialize {
    my($self) = @_;
    $self->put(html_format => b_use('HTMLFormat.Dollar'));
    return $self->SUPER::initialize(@_);
}

1;
