# Copyright (c) 2004-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Format::Dollar;
use strict;
use Bivio::Base 'HTMLFormat.Amount';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_widget_value {
    my($self, $amount) = @_;
    return '$' . shift->SUPER::get_widget_value(@_);
}

1;
