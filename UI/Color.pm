# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Color;
use strict;
$Bivio::UI::Color::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Color::VERSION;

=head1 NAME

Bivio::UI::Color - named colors

=head1 SYNOPSIS

    use Bivio::UI::Color;

=cut

=head1 EXTENDS

L<Bivio::UI::FacadeComponent>

=cut

use Bivio::UI::FacadeComponent;
@Bivio::UI::Color::ISA = ('Bivio::UI::FacadeComponent');

=head1 DESCRIPTION

C<Bivio::UI::Color> is a map of names to RGB color values.  The
color values are represented integers.  If a color is negative,
it means "no color".

=cut


=head1 CONSTANTS

=cut

=for html <a name="UNDEF_CONFIG"></a>

=head2 UNDEF_CONFIG() : int

Returns "no color" config.

=cut

sub UNDEF_CONFIG {
    return -1;
}

#=IMPORTS
use Bivio::UI::Facade;

#=VARIABLES
Bivio::UI::Facade->register;

=head1 METHODS

=cut

=for html <a name="format_html"></a>

=head2 static format_html(string name, string attr, Bivio::Collection::Attributes req_or_facade) : string

=head2 format_html(string name, string attr) : string

Returns the color as an attribute=value string suitable for HTML,
with a I<leading space>.

If I<attr> contains a ':', returns a style attribute instead, e.g.

    color: "#abcdef";

If I<attr> is the empty string, returns just the number sans quotes:

    #abcdef

If I<name> is false (0, C<undef>, ''), returns an empty string.

See
L<Bivio::UI::FacadeComponent::internal_get_value|Bivio::UI::FacadeComponent/"internal_get_value">
for description of last argument.


=cut

sub format_html {
    my($proto, $name, $attr, $req) = @_;
    return '' unless $name;

    # Lookup name
    my($v) = $proto->internal_get_value($name, $req);
    return '' unless $v;

    # Return cached value
    return defined($attr) && defined($v->{$attr}) ? $v->{$attr}
	    : _format_html($v->{config}, $attr);
}

=for html <a name="internal_initialize_value"></a>

=head2 internal_initialize_value(hash_ref value)

Outputs a warning if not a valid value.  Always successful.

=cut

sub internal_initialize_value {
    my($self, $value) = @_;
    my($v) = $value->{config};
    unless ($v =~ /^-?\d+$/) {
	$self->bad_value($value, 'not an integer');
	# Mark as "no color"
	$v = -1;
    }

    # Cache the most commonly used values
    $value->{bgcolor} = _format_html($v, 'bgcolor');
    $value->{color} = _format_html($v, 'color');
    return;
}

#=PRIVATE METHODS

# _format_html(int num, string attr) : string
#
# Formats the color attribute or style.
#
sub _format_html {
    my($num, $attr) = @_;
    return '' if $num < 0;
    return sprintf('#%06X', $num) unless length($attr);
    return sprintf($attr =~ /:/ ? '%s "#%06X";' : ' %s="#%06X"',
	    $attr, $num);
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
