# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Font;
use strict;
$Bivio::UI::Font::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Font - named fonts

=head1 SYNOPSIS

    use Bivio::UI::Font;

=cut

=head1 EXTENDS

L<Bivio::UI::FacadeComponent>

=cut

use Bivio::UI::FacadeComponent;
@Bivio::UI::Font::ISA = ('Bivio::UI::FacadeComponent');

=head1 DESCRIPTION

C<Bivio::UI::Font> is a map of font names to html values.

The configuration of a font is an array_ref.  The elements are:

    [
        face(s),
        color,
        modifiers,
    ],

The face(s) is a list of valid HTML font face, e.g.
C<verdana,sans,serif,>.  The color must be a valid
L<Bivio::UI::Color|Bivio::UI::Color>.  The modifiers
one of the various HTML font modifiers, e.g. C<strong>,
C<tt>, and C<small> or a C<FONT> tag attribute,
e.g. "size=+1" and "class=content".

=cut


=head1 CONSTANTS

=cut

=for html <a name="UNDEF_CONFIG"></a>

=head2 UNDEF_CONFIG : array_ref

Returns config for no font.

=cut

sub UNDEF_CONFIG {
    return [];
}

#=IMPORTS
use Bivio::UI::Color;
use Bivio::UI::Facade;

#=VARIABLES
Bivio::UI::Facade->register(['Bivio::UI::Color']);

=head1 METHODS

=cut

=for html <a name="format_html"></a>

=head2 static format_html(string name, Bivio::Collection::Attributes req_or_facade) : array

=head2 format_html(string name) : array

Returns the font as prefix and suffix strings to surround the text with.

If I<thing> returns false (zero or C<undef>), returns two empty
strings.

See
L<Bivio::UI::FacadeComponent::internal_get_value|Bivio::UI::FacadeComponent/"internal_get_value">
for description of last argument.

=cut

sub format_html {
    my($proto, $name, $req) = @_;
    return ('', '') unless $name;

    # Lookup name
    my($v) = $proto->internal_get_value($name, $req);
    return $v ? @{$v->{value}} : ('', '');
}

=for html <a name="internal_initialize_value"></a>

=head2 internal_initialize_value(hash_ref value, string name)

Initializes the internal value from the configuration.

=cut

sub internal_initialize_value {
    my($self, $value, $name) = @_;
    my($v) = $value->{config};
    unless (ref($v) eq 'ARRAY') {
	$self->bad_value($value, $name, 'not an array_ref');
	$v = $value->{config} = [];
    }

    my($face, $color, @styles) = @$v;
    my($p, $s) = ('', '');
    my($attrs) = '';
    while (@styles) {
	my($style) = shift(@styles);
	if ($style =~ /=/) {
	    $attrs .= ' '.$style;
	    next;
	}
	$p .= "<$style>";
	$s = "</$style>" . $s;
    }

    if ($color || $face || $attrs) {
	$p .= '<font';
	$p .= ' face="'.$face.'"' if $face;
	$p .= Bivio::UI::Color->format_html($color, 'color', $self->get_facade)
		if $color;
	$p .= $attrs;
	$p .= '>';
	$s = '</font>' . $s;
    }
    $value->{value} = [$p, $s];
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
