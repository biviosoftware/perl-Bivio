# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::ComboBox;
use strict;
use Bivio::Base 'XHTMLWidget';


sub internal_cb_size {
    my($self) = @_;
    # this size is used for inline forms, other forms at 100%
    return 40;
}

sub internal_cb_text_class {
    return 'cb_text form-control';
}

1;
