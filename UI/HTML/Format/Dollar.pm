# Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Format::Dollar;
use strict;
use Bivio::Base 'Bivio::UI::HTML::Format::Amount';

# C<Bivio::UI::HTML::Format::Dollar>

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_widget_value {
    # (proto, string, int, boolean, boolean) : string
    # Formats like Amount but with leading $.  See
    # L<Bivio::UI::HTML::Format::Amount|Bivio::UI::HTML::Format::Amount>
    # for arguments.
    my($self, $amount) = @_;
    return '$' . shift->SUPER::get_widget_value(@_);
}

1;
