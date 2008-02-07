# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Color;
use strict;
use Bivio::Base 'UI.FacadeComponent';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub UNDEF_CONFIG {
    return -1;
}

sub format_css {
    # Returns color: #<color>;
    #
    # If name is hyphenated, the name is hyphens are converted to underscores, and
    # the attribute is the rest of the hyphenation, e.g.
    #
    #     format_css('acknowledgement-border') -> border-color: #0;
    #
    # The value of acknowledgement_border is #0.
    my($proto, $name, $req_or_facade) = @_;
    my($attr) = 'color:';
    if ($name =~ /-(.*)/) {
	$attr = "$1-$attr";
	$name =~ s/-/_/g;
    }
    return $proto->format_html($name, $attr, $req_or_facade);
}

sub format_html {
    # (proto, string, string, Collection.Attributes) : string
    # (self, string, string) : string
    # Returns the color as an attribute=value string suitable for HTML,
    # with a I<leading space>.
    #
    # If I<attr> contains a ':', returns a style attribute instead, e.g.
    #
    #     color: #abcdef;
    #
    # If I<attr> is the empty string, returns just the number sans quotes:
    #
    #     #abcdef
    #
    # If I<name> is false (0, C<undef>, ''), returns an empty string.
    #
    # See
    # L<Bivio::UI::FacadeComponent::internal_get_value|Bivio::UI::FacadeComponent/"internal_get_value">
    # for description of last argument.
    my($proto, $name, $attr, $req) = @_;
    return ''
	unless $name and my $v = $proto->internal_get_value($name, $req);
    return defined($attr) && defined($v->{$attr}) ? $v->{$attr}
	    : _format_html($v->{config}, $attr);
}

sub handle_register {
    my($proto) = @_;
    Bivio::UI::Facade->register($proto);
    return;
}

sub internal_initialize_value {
    my($self, $value) = @_;
    my($v) = $value->{config};
    unless ($v =~ /^-?\d+$/) {
	$self->initialization_error($value, 'not an integer');
	$v = $self->UNDEF_CONFIG;
    }
    $value->{bgcolor} = _format_html($v, 'bgcolor');
    $value->{color} = _format_html($v, 'color');
    return;
}

sub _format_html {
    my($num, $attr) = @_;
    return $num < 0 ? ''
        : length($attr)
	? sprintf($attr =~ /:/ ? '%s #%06X;' : ' %s="#%06X"', $attr, $num)
	: sprintf('#%06X', $num);
}

1;
