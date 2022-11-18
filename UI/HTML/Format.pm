# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format;
use strict;
use Bivio::Base 'UI.WidgetValueSource';

# C<Bivio::UI::HTML::Format> is the superclass of HTML widget value formatters.
# Typically, this class sits first the the L<get_widget_value|"get_widget_value">
# parameter list, e.g.
#
#     value => [HTMLFormat.DateTime => request => 'start_time'];
#
# Formatters transform widget values into something "renderable".  This may
# involve querying user preferences to determine how the user likes to
# see things, e.g. date/time format.


sub get_instance {
    my($proto, $class) = @_;
    $class = b_use('HTMLFormat', $class)
        unless ref($class);
    b_die($class, ': not a ', $proto->package_name)
        unless $proto->is_super_of($class);
    return $class;
}

sub result_is_html {
    return 0;
}

1;
