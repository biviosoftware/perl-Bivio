# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format;
use strict;
$Bivio::UI::HTML::Format::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Format - superclass of widget value formatters

=head1 SYNOPSIS

    use Bivio::UI::HTML::Format;
    Bivio::UI::HTML::Format->get_widget_value($source, @params);

=cut

=head1 EXTENDS

L<Bivio::UNIVERSAL>

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::HTML::Format::ISA = ('Bivio::UNIVERSAL');

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

#=VARIABLES


=head1 METHODS

=cut

=for html <a name="get_widget_value"></a>

=head2 abstract static get_widget_value(string source, any arg1, ...) : any

Calls C<$source->get_widget_value(arg1, ...)>, formats the result,
and returns it.

=cut

sub get_widget_value {
    die('abstract method');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
