# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::BR;
use strict;
use base 'Bivio::UI::HTML::Widget::Tag';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_new_args {
    return shift->SUPER::internal_new_args(div => '', @_);
}

1;
