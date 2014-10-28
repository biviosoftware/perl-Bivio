# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Widget::CreditCardExpiration;
use strict;
use Bivio::Base 'Widget.Simple';

my($_D) = b_use('Type.Date');

sub render {
    my($self, $source, $buffer) = @_;
    my($date) = $source->get_widget_value($self->get('value'));
    $$buffer .= b_use('Type.Month')->from_int(
        $_D->get_part($date, 'month'))->get_short_desc
        . ' ' . $_D->get_part($date, 'year');
    return;
}

1;
