# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format::Printf;
use strict;
$Bivio::UI::HTML::Format::Printf::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Format::Printf - allows printf formatting of values

=head1 SYNOPSIS

    use Bivio::UI::HTML::Format::Printf;
    Bivio::UI::HTML::Format::Printf->get_widget_value($value, $format);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Format>

=cut

use Bivio::UI::HTML::Format;
@Bivio::UI::HTML::Format::Printf::ISA = ('Bivio::UI::HTML::Format');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Format::Printf> formats a value using C<sprintf>.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_widget_value"></a>

=head2 static get_widget_value(any value, string format) : string

Formats a value using C<sprintf>.

=cut

sub get_widget_value {
    my(undef, $value, $format) = @_;
    return sprintf($format, $value);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
