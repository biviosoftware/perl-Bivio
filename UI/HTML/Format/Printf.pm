# Copyright (c) 1999 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format::Printf;
use strict;
use Bivio::Base 'Bivio::UI::HTML::Format';

# C<Bivio::UI::HTML::Format::Printf> formats a value using C<sprintf>.


sub get_widget_value {
    my(undef, $value, $format) = @_;
    return '' unless defined($value);
    return sprintf($format, $value);
}

1;
