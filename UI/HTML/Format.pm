# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format;
use strict;
$Bivio::UI::HTML::Format::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Format::VERSION;

=head1 NAME

Bivio::UI::HTML::Format - superclass of widget value formatters

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Format;

=cut

=head1 EXTENDS

L<Bivio::UI::WidgetValueSource>

=cut

use Bivio::UI::WidgetValueSource;
@Bivio::UI::HTML::Format::ISA = ('Bivio::UI::WidgetValueSource');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Format> is the superclass of HTML widget value formatters.
Typically, this class sits first the the L<get_widget_value|"get_widget_value">
parameter list, e.g.

    value => [Bivio::UI::HTML::Format::DateTime =>
              request => 'start_time'];

Formatters transform widget values into something "renderable".  This may
involve querying user preferences to determine how the user likes to
see things, e.g. date/time format.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::IO::ClassLoader;
use Bivio::HTML;

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="get_instance"></a>

=head2 static get_instance() : Bivio::UI::HTML::Format

=head2 static get_instance(any class) : Bivio::UI::HTML::Format

Returns an instance of I<class>.  I<class> may be just the simple name or a
fully qualified class name.  It will be loaded with
L<Bivio::IO::ClassLoader|Bivio::IO::ClassLoader> using the I<HTMLFormat> map.

The "instance" returned may a fully-qualified class, since instances and
classes are equivalent in perl.

=cut

sub get_instance {
    my($proto, $class) = @_;
    $class = Bivio::IO::ClassLoader->map_require('HTMLFormat', $class)
	    unless ref($class);
    Bivio::IO::Alert->bootstrap_die($class, ': not a Bivio::UI::HTML::Format')
		unless UNIVERSAL::isa($class, 'Bivio::UI::HTML::Format');
    return $class;
}

=head1 METHODS

=cut

=for html <a name="result_is_html"></a>

=head2 result_is_html() : boolean

Returns true if the result is html.

False by default.

=cut

sub result_is_html {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
