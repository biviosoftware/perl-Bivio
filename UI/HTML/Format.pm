# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format;
use strict;
use Bivio::Base 'Bivio::UI::WidgetValueSource';
use Bivio::Die;
use Bivio::HTML;
use Bivio::IO::ClassLoader;

# C<Bivio::UI::HTML::Format> is the superclass of HTML widget value formatters.
# Typically, this class sits first the the L<get_widget_value|"get_widget_value">
# parameter list, e.g.
#
#     value => [Bivio::UI::HTML::Format::DateTime =>
#               request => 'start_time'];
#
# Formatters transform widget values into something "renderable".  This may
# involve querying user preferences to determine how the user likes to
# see things, e.g. date/time format.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_instance {
    # (proto) : HTML.Format
    # (proto, any) : HTML.Format
    # Returns an instance of I<class>.  I<class> may be just the simple name or a
    # fully qualified class name.  It will be loaded with
    # L<Bivio::IO::ClassLoader|Bivio::IO::ClassLoader> using the I<HTMLFormat> map.
    #
    # The "instance" returned may a fully-qualified class, since instances and
    # classes are equivalent in perl.
    my($proto, $class) = @_;
    $class = Bivio::IO::ClassLoader->map_require('HTMLFormat', $class)
	    unless ref($class);
    Bivio::IO::Alert->bootstrap_die($class, ': not a Bivio::UI::HTML::Format')
		unless UNIVERSAL::isa($class, 'Bivio::UI::HTML::Format');
    return $class;
}

sub result_is_html {
    # (self) : boolean
    # Returns true if the result is html.
    #
    # False by default.
    return 0;
}

1;
